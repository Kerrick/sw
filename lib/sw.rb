# frozen_string_literal: true

require "rooibos"
require_relative "sw/character"
require_relative "sw/value"
require_relative "sw/vehicle"
require_relative "sw/collection"
require_relative "sw/load"
require_relative "sw/load/mapper"
require_relative "sw/characters"
require_relative "sw/search"
require_relative "sw/selected_character"
require_relative "sw/films"
require_relative "sw/starships"
require_relative "sw/vehicles"

# The Star Wars Character Datapad.
module Sw
  include Rooibos::Router

  API_URL = "https://swapi.info/api"

  Model = Data.define(:characters, :failure, :loading, :focus, :search) do
    def initialize(characters:, failure: nil, loading: false, focus: :characters, search: Search::Init.call) = super

    alias_method :loading?, :loading
  end

  Download = -> { Load.new(url: ENV.fetch("SW_API_URL", API_URL)) }

  Init = -> { [Model.new(characters: nil, loading: true), Download.call] }

  Title = -> (tui) { tui.paragraph(text: "Star Wars Character Datapad", style: tui.style(modifiers: [:bold])) }

  # A status word takes no width when absent. Blue is for ephemeral status.
  StatusWord = -> (tui, word, color) {
    [tui.text_span(content: word, style: tui.style(fg: color)), tui.text_span(content: " ")]
  }

  Hotkey = -> (tui, key, label) {
    [tui.text_span(content: key, style: tui.style(modifiers: [:bold, :underlined])), tui.text_span(content: ": #{label}")]
  }

  GlobalKeys = [["r", "Reload"], ["q", "Quit"]].freeze

  # The focused panel's keys come first, then the keys that work everywhere.
  StatusLine = -> (tui, status: [], keys: []) {
    hotkeys = [*keys, *GlobalKeys].map { |key, label| Hotkey.call(tui, key, label) }
    tui.paragraph(text: [
      tui.text_line(spans: [*status, *hotkeys.flat_map { |spans| [*spans, tui.text_span(content: "  ")] }.slice(0...-1)]),
    ])
  }

  # The title and key help around one body, for screens without panels.
  Wrapper = -> (tui, body, status: []) {
    tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(1), tui.constraint_fill(1), tui.constraint_length(1)],
      children: [Title.call(tui), body, StatusLine.call(tui, status:)]
    )
  }

  # A one-line box, centered both ways. Its height fits its text, so the text is centered too.
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

  View = -> (model, tui) {
    return FailureView.call(model, tui) if model.failure
    return LoadingView.call(tui) unless model.characters

    selected = model.characters.selected

    tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(1), tui.constraint_fill(3), tui.constraint_fill(1), tui.constraint_fill(2), tui.constraint_length(1)],
      children: [
        Title.call(tui),
        tui.layout(
          direction: :horizontal,
          constraints: [tui.constraint_length(27), tui.constraint_fill(1)],
          children: [
            Characters::View.call(model.characters, tui, focused: model.focus == :characters),
            SelectedCharacter::View.call(selected, tui),
          ]
        ),
        Films::View.call(tui),
        tui.layout(
          direction: :horizontal,
          constraints: [tui.constraint_fill(1), tui.constraint_fill(1)],
          children: [Starships::View.call(tui), Vehicles::View.call(selected&.vehicles, tui)]
        ),
        StatusLine.call(tui, status: model.loading? ? StatusWord.call(tui, "Loading", :blue) : [], keys: (model.focus == :characters) ? Characters::Keys : []),
      ]
    )
  }

  action :quit, -> { Rooibos::Command.exit }

  action :reload, -> (_, model) { [model.with(failure: nil, loading: true), Download.call] }

  receive_events %i[q ctrl_c], :quit
  receive_events %i[r f5], :reload

  route :characters, to: Characters
  route :search, to: Search

  forward_instances_of Search::QueryChanged, to: :characters, as: :filter

  only when: -> (_, model) { model.characters } do
    receive_events %i[1 /], -> (_, model) { model.with(focus: :search) }
    receive_events :"2", -> (_, model) { model.with(focus: :characters) }

    only when: -> (_, model) { model.focus == :characters } do
      forward_events %i[down j], to: :characters, as: :move_down
      forward_events %i[up k], to: :characters, as: :move_up
      forward_events %i[home g], to: :characters, as: :move_first
      forward_events %i[end shift_G], to: :characters, as: :move_last
    end

    # Search takes every keystroke nothing above answered.
    only when: -> (_, model) { model.focus == :search } do
      otherwise route_to: :search
    end
  end

  receive_instances_of Load::Finished, -> (message, model) {
    model.with(characters: Characters::Init.(characters: message.characters), loading: false)
  }

  receive_instances_of Load::Failed, -> (message, model) {
    model.with(failure: message.reason, loading: false)
  }

  Update = from_router
end
