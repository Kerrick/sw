# frozen_string_literal: true

require "rooibos"
require_relative "sw/planet"
require_relative "sw/character"
require_relative "sw/species"
require_relative "sw/value"
require_relative "sw/vehicle"
require_relative "sw/starship"
require_relative "sw/film"
require_relative "sw/collection"
require_relative "sw/load"
require_relative "sw/load/mapper"
require_relative "sw/load/cache"
require_relative "sw/load/run"
require_relative "sw/characters"
require_relative "sw/search"
require_relative "sw/selected_character"
require_relative "sw/values"
require_relative "sw/empty"
require_relative "sw/craft"
require_relative "sw/attributes_box"
require_relative "sw/homeworld_box"
require_relative "sw/species_box"
require_relative "sw/films"
require_relative "sw/starships"
require_relative "sw/vehicles"

# The Star Wars Character Datapad.
module Sw
  include Rooibos::Router

  API_URL = "https://swapi.info/api"

  Model = Data.define(:characters, :films, :failure, :loading, :focus, :search) do
    def initialize(characters:, films:, failure: nil, loading: false, focus: :characters, search: Search::Init.call) = super

    alias_method :loading?, :loading
  end

  # The panels that take focus, in reading order. Tab moves through them, and the number keys count them from 1.
  FocusOrder = %i[search characters].freeze

  FocusStep = -> (model, step) { model.with(focus: FocusOrder[(FocusOrder.index(model.focus) + step) % FocusOrder.size]) }

  Init = -> { [Model.new(characters: nil, films: nil, loading: true), Load.new] }

  TITLE = "Star Wars Character Datapad"

  Title = -> (tui) { tui.paragraph(text: TITLE, style: tui.style(modifiers: [:bold])) }

  # A status word takes no width when absent. Blue is for ephemeral status.
  StatusWord = -> (tui, word, color) {
    [tui.text_span(content: word, style: tui.style(fg: color)), tui.text_span(content: " ")]
  }

  Hotkey = -> (tui, key, label) {
    [tui.text_span(content: key, style: tui.style(modifiers: [:bold, :underlined, :dim])), tui.text_span(content: ": #{label}", style: tui.style(modifiers: [:dim]))]
  }

  GlobalKeys = [["r", "Reload"], ["q", "Quit"]].freeze

  StatusLine = -> (tui, status: [], keys: []) {
    hotkeys = keys.map { |key, label| Hotkey.call(tui, key, label) }
    tui.paragraph(text: [
      tui.text_line(spans: [*status, *hotkeys.flat_map { |spans| [*spans, tui.text_span(content: "  ")] }.slice(0...-1)]),
    ])
  }

  # Search is as wide as the list.
  ListWidth = 27

  # The title over the status line, with Search beside them once there is data to search.
  Header = -> (tui, status_line, search = nil) {
    title_and_status = tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(1), tui.constraint_fill(1), tui.constraint_length(1)],
      children: [Title.call(tui), tui.paragraph(text: ""), status_line]
    )
    return title_and_status unless search

    tui.layout(direction: :horizontal, constraints: [tui.constraint_fill(1), tui.constraint_length(ListWidth)], children: [title_and_status, search])
  }

  # The header around one body, for screens without panels.
  Wrapper = -> (tui, body, status: []) {
    tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(3), tui.constraint_fill(1)],
      children: [Header.call(tui, StatusLine.call(tui, status:, keys: GlobalKeys)), body]
    )
  }

  LoadingView = -> (tui) {
    spacer = tui.paragraph(text: "")
    box = tui.paragraph(text: "Loading the Datapad…", alignment: :center, block: tui.block(borders: [:all]))
    Wrapper.call(
      tui,
      tui.layout(
        direction: :vertical,
        constraints: [tui.constraint_fill(1), tui.constraint_length(3), tui.constraint_fill(1)],
        children: [
          spacer,
          tui.layout(
            direction: :horizontal,
            constraints: [tui.constraint_fill(1), tui.constraint_length(30), tui.constraint_fill(1)],
            children: [spacer, box, spacer]
          ),
          spacer,
        ]
      ),
      status: StatusWord.call(tui, "Loading", :blue)
    )
  }

  FailureView = -> (model, tui) {
    Wrapper.call(
      tui,
      tui.center(
        child: tui.paragraph(
          text: model.failure,
          wrap: true,
          block: tui.block(title: "Couldn't load the data", title_style: tui.style(modifiers: [:bold]), borders: [:all])
        ),
        width_percent: 60,
        height_percent: 40
      ),
      status: StatusWord.call(tui, "Error", :red)
    )
  }

  # Starships and Vehicles take no focus, so they can't scroll. Their row is tall enough for the most of either that any
  # character pilots, each in three rows and a rule, so it holds still as the highlight moves.
  CraftHeight = -> (characters) {
    most = characters.map { |character| [character.vehicles.count, character.starships.count].max }.max.to_i
    ([most, 1].max * 4) + 1
  }

  View = -> (model, tui) {
    # The error screen is only for having no data. A failed reload leaves the old data on screen.
    return FailureView.call(model, tui) if model.failure && !model.characters
    return LoadingView.call(tui) unless model.characters

    selected = model.characters.selected
    status = if model.loading?
      StatusWord.call(tui, "Reloading", :blue)
    elsif model.failure
      StatusWord.call(tui, "Reload failed", :red)
    else
      []
    end

    tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(3), tui.constraint_fill(3), tui.constraint_fill(1), tui.constraint_length(CraftHeight.(model.characters.collection))],
      children: [
        Header.call(
          tui,
          StatusLine.call(tui, status:, keys: (model.focus == :characters) ? [*Characters::Keys, *([Search::ClearKey] unless model.search.query.empty?), *GlobalKeys] : Search::Keys),
          Search::View.call(model.search, tui, focused: model.focus == :search, number: FocusOrder.index(:search) + 1)
        ),
        tui.layout(
          direction: :horizontal,
          constraints: [tui.constraint_length(ListWidth), tui.constraint_fill(1)],
          children: [
            Characters::View.call(model.characters, tui, number: FocusOrder.index(:characters) + 1, focused: model.focus == :characters),
            SelectedCharacter::View.call(selected, tui),
          ]
        ),
        Films::View.call(model.films, selected&.films, tui),
        tui.layout(
          direction: :horizontal,
          constraints: [tui.constraint_fill(1), tui.constraint_fill(1)],
          children: [Starships::View.call(selected&.starships, tui), Vehicles::View.call(selected&.vehicles, tui)]
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

    receive_events :tab, -> (_, model) { FocusStep.(model, 1) }
    receive_events %i[back_tab shift_back_tab], -> (_, model) { FocusStep.(model, -1) }

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
    loaded = model.with(characters: Characters::Init.(characters: message.characters, query: model.search.query), films: message.films, loading: message.stale)
    message.stale ? [loaded, Load.new(reload: true)] : loaded
  }

  receive_instances_of Load::Failed, -> (message, model) {
    model.with(failure: message.reason, loading: false)
  }

  Update = from_router
end
