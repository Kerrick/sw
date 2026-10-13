# frozen_string_literal: true

# The root fragment: the one screen, and which panel has focus.
module Sw
  include Rooibos::Router

  Model = Data.define(:characters, :films, :failure, :loading, :focus, :search) do
    def initialize(characters:, films:, failure: nil, loading: false, focus: :characters, search: Search::Init.call) = super

    alias_method :loading?, :loading
  end

  # The panels that take focus, in reading order. Tab moves through them, and the number keys count them from 1.
  FocusOrder = %i[search characters].freeze

  FocusStep = -> (model, step) { model.with(focus: FocusOrder[(FocusOrder.index(model.focus) + step) % FocusOrder.size]) }

  Init = -> { [Model.new(characters: nil, films: nil, loading: true), Load.new] }

  # Search is as wide as the list.
  ListWidth = 27

  # The header around one body, for screens without panels.
  Wrapper = -> (body, tui, status: []) {
    tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(3), tui.constraint_fill(1)],
      children: [
        Header::View.call(
          StatusLine::View.call(tui, status:, keys: StatusLine::GlobalKeys),
          tui
        ),
        body,
      ]
    )
  }

  LoadingView = -> (tui) {
    spacer = tui.paragraph(text: "")
    Wrapper.call(
      tui.layout(
        direction: :vertical,
        constraints: [
          tui.constraint_fill(1),
          tui.constraint_length(3),
          tui.constraint_fill(1),
        ],
        children: [
          spacer,
          tui.layout(
            direction: :horizontal,
            constraints: [
              tui.constraint_fill(1),
              tui.constraint_length(30),
              tui.constraint_fill(1),
            ],
            children: [
              spacer,
              tui.paragraph(
                text: "Loading the Datapad…",
                alignment: :center,
                block: tui.block(borders: [:all])
              ),
              spacer,
            ]
          ),
          spacer,
        ]
      ),
      tui,
      status: StatusLine::Word.call("Loading", :blue, tui)
    )
  }

  FailureView = -> (model, tui) {
    Wrapper.call(
      tui.center(
        child: tui.paragraph(
          text: model.failure,
          wrap: true,
          block: tui.block(
            title: "Couldn't load the data",
            title_style: tui.style(modifiers: [:bold]),
            borders: [:all]
          )
        ),
        width_percent: 60,
        height_percent: 40
      ),
      tui,
      status: StatusLine::Word.call("Error", :red, tui)
    )
  }

  View = -> (model, tui) {
    # The error screen is only for having no data. A failed reload leaves the old data on screen.
    return FailureView.call(model, tui) if model.failure && !model.characters
    return LoadingView.call(tui) unless model.characters

    selected = model.characters.selected
    status = if model.loading?
      StatusLine::Word.call("Reloading", :blue, tui)
    elsif model.failure
      StatusLine::Word.call("Reload failed", :red, tui)
    else
      []
    end
    keys = if model.focus == :characters
      [*Characters::Keys, *([Search::ClearKey] unless model.search.query.empty?), *StatusLine::GlobalKeys]
    else
      Search::Keys
    end

    tui.layout(
      direction: :vertical,
      constraints: [
        tui.constraint_length(3),
        tui.constraint_fill(3),
        tui.constraint_fill(1),
        tui.constraint_length(Craft::Height.call(model.characters.collection)),
      ],
      children: [
        Header::View.call(
          StatusLine::View.call(tui, status:, keys:),
          tui,
          search: Search::View.call(
            model.search,
            tui,
            focused: model.focus == :search,
            number: FocusOrder.index(:search) + 1
          )
        ),
        tui.layout(
          direction: :horizontal,
          constraints: [tui.constraint_length(ListWidth), tui.constraint_fill(1)],
          children: [
            Characters::View.call(
              model.characters,
              tui,
              number: FocusOrder.index(:characters) + 1,
              focused: model.focus == :characters
            ),
            SelectedCharacter::View.call(selected, tui),
          ]
        ),
        Films::View.call(model.films, selected&.films, tui),
        tui.layout(
          direction: :horizontal,
          constraints: [tui.constraint_fill(1), tui.constraint_fill(1)],
          children: [
            Starships::View.call(selected&.starships, tui),
            Vehicles::View.call(selected&.vehicles, tui),
          ]
        ),
      ]
    )
  }

  # While Search has focus, it types the keys other panels act on, so those panels skip them.
  Searching = Ractor.shareable_lambda { |_, model| model.focus == :search }

  action :quit, -> { Rooibos::Command.exit }

  action :reload, -> (_, model) { [model.with(failure: nil, loading: true), Load.new(reload: true)] }

  receive_events :ctrl_c, :quit
  receive_events :f5, :reload

  skip when: Searching do
    receive_events :q, :quit
    receive_events :r, :reload
  end

  route :characters, to: Characters
  route :search, to: Search

  forward_instances_of Search::QueryChanged, to: :characters, as: :filter

  only when: -> (_, model) { model.characters } do
    skip when: Searching do
      receive_events :/, -> (_, model) { model.with(focus: :search) }
      FocusOrder.each.with_index(1) do |panel, number|
        receive_events :"#{number}", -> (_, model) { model.with(focus: panel) }
      end
    end

    receive_events :tab, -> (_, model) { FocusStep.call(model, 1) }
    receive_events %i[back_tab shift_back_tab], -> (_, model) { FocusStep.call(model, -1) }

    # Esc clears the search from either panel and lands on the list.
    observe_events :esc, -> (_, model) { model.with(focus: :characters) }
    forward_events :esc, to: :search, as: :clear

    only when: -> (_, model) { model.focus == :characters } do
      forward_events %i[down j], to: :characters, as: :move_down
      forward_events %i[up k], to: :characters, as: :move_up
      forward_events %i[home g], to: :characters, as: :move_first
      forward_events %i[end shift_G], to: :characters, as: :move_last
    end

    only when: Searching do
      receive_events :enter, -> (_, model) { model.with(focus: :characters) }
      otherwise route_to: :search
    end
  end

  receive_instances_of Load::Finished, -> (message, model) {
    characters = Characters::Init.call(characters: message.characters, query: model.search.query, selected: model.characters&.selected)
    loaded = model.with(characters:, films: message.films, loading: message.stale)
    message.stale ? [loaded, Load.new(reload: true)] : loaded
  }

  receive_instances_of Load::Failed, -> (message, model) {
    model.with(failure: message.reason, loading: false)
  }

  Update = from_router
end
