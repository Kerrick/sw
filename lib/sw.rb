# frozen_string_literal: true

require "rooibos"
require_relative "sw/character"
require_relative "sw/vehicle"
require_relative "sw/collection"
require_relative "sw/load"
require_relative "sw/load/mapper"
require_relative "sw/characters"

# The Star Wars Character Datapad.
module Sw
  include Rooibos::Router

  API_URL = "https://swapi.info/api"

  Model = Data.define(:characters, :failure, :loading) do
    def initialize(characters:, failure: nil, loading: false) = super

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

  KeyHelp = -> (tui, status: []) {
    tui.paragraph(text: [
      tui.text_line(spans: [*status, *Hotkey.call(tui, "r", "Reload"), tui.text_span(content: "  "), *Hotkey.call(tui, "q", "Quit")]),
    ])
  }

  # The title and key help around one body, for screens without panels.
  Wrapper = -> (tui, body, status: []) {
    tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(1), tui.constraint_fill(1), tui.constraint_length(1)],
      children: [Title.call(tui), body, KeyHelp.call(tui, status:)]
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

    tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(1), tui.constraint_fill(3), tui.constraint_fill(1), tui.constraint_fill(2), tui.constraint_length(1)],
      children: [
        Title.call(tui),
        tui.layout(
          direction: :horizontal,
          constraints: [tui.constraint_length(27), tui.constraint_fill(1)],
          children: [
            Characters::View.call(model.characters, tui),
            tui.block(
              title: model.characters.selected&.name.to_s,
              title_style: tui.style(modifiers: [:bold]),
              borders: [:all]
            ),
          ]
        ),
        tui.block(title: "Films", borders: [:all]),
        tui.layout(
          direction: :horizontal,
          constraints: [tui.constraint_fill(1), tui.constraint_fill(1)],
          children: [tui.block(title: "Starships", borders: [:all]), tui.block(title: "Vehicles", borders: [:all])]
        ),
        KeyHelp.call(tui, status: model.loading? ? StatusWord.call(tui, "Loading", :blue) : []),
      ]
    )
  }

  action :quit, -> { Rooibos::Command.exit }

  action :reload, -> (_, model) { [model.with(failure: nil, loading: true), Download.call] }

  receive_events %i[q ctrl_c], :quit
  receive_events %i[r f5], :reload

  receive_instances_of Load::Finished, -> (message, model) {
    model.with(characters: Characters::Init.(characters: message.characters), loading: false)
  }

  receive_instances_of Load::Failed, -> (message, model) {
    model.with(failure: message.reason, loading: false)
  }

  Update = from_router
end
