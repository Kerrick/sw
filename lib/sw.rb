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

  Model = Data.define(:characters, :failure) do
    def initialize(characters:, failure: nil) = super
  end

  Init = -> {
    [Model.new(characters: Characters::Init.(characters: Collection.new([]))), Load.new(url: ENV.fetch("SW_API_URL", API_URL))]
  }

  Title = -> (tui) { tui.paragraph(text: "Star Wars Character Datapad", style: tui.style(modifiers: [:bold])) }

  KeyHelp = -> (tui) {
    tui.paragraph(text: [
      tui.text_line(spans: [
        tui.text_span(content: "q", style: tui.style(modifiers: [:bold, :underlined])),
        tui.text_span(content: ": Quit"),
      ]),
    ])
  }

  FailureView = -> (model, tui) {
    tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(1), tui.constraint_fill(1), tui.constraint_length(1)],
      children: [
        Title.call(tui),
        tui.center(
          child: tui.paragraph(
            text: model.failure,
            wrap: true,
            block: tui.block(title: "Couldn't load the data", title_style: tui.style(modifiers: [:bold]), borders: [:all])
          ),
          width_percent: 60,
          height_percent: 40
        ),
        KeyHelp.call(tui),
      ]
    )
  }

  View = -> (model, tui) {
    return FailureView.call(model, tui) if model.failure

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
        KeyHelp.call(tui),
      ]
    )
  }

  action :quit, -> { Rooibos::Command.exit }

  receive_events %i[q ctrl_c], :quit

  receive_instances_of Load::Finished, -> (message, model) {
    model.with(characters: Characters::Init.(characters: message.characters))
  }

  receive_instances_of Load::Failed, -> (message, model) {
    model.with(failure: message.reason)
  }

  Update = from_router
end
