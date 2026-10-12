# frozen_string_literal: true

require "rooibos"
require_relative "sw/character"
require_relative "sw/vehicle"
require_relative "sw/collection"
require_relative "sw/loaded"
require_relative "sw/load"
require_relative "sw/load/mapper"
require_relative "sw/characters"

# The Star Wars Character Datapad.
module Sw
  include Rooibos::Router

  API_URL = "https://swapi.info/api"

  Model = Data.define(:characters)

  Init = -> {
    [Model.new(characters: Characters::Init.(characters: Collection.new([]))), Load.new(url: ENV.fetch("SW_API_URL", API_URL))]
  }

  View = -> (model, tui) {
    tui.layout(
      direction: :vertical,
      constraints: [tui.constraint_length(1), tui.constraint_fill(3), tui.constraint_fill(1), tui.constraint_fill(2)],
      children: [
        tui.paragraph(text: "Star Wars Character Datapad", style: tui.style(modifiers: [:bold])),
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
      ]
    )
  }

  action :quit, -> { Rooibos::Command.exit }

  receive_events :ctrl_c, :quit

  receive_instances_of Loaded, -> (message, model) {
    model.with(characters: Characters::Init.(characters: message.characters))
  }

  Update = from_router
end
