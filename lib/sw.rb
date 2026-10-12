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

  Init = -> { [Model.new(characters: Collection.new([])), Load.new(url: ENV.fetch("SW_API_URL", API_URL))] }

  View = -> (model, tui) { Characters::View.call(model.characters, tui) }

  action :quit, -> { Rooibos::Command.exit }

  receive_events :ctrl_c, :quit

  receive_instances_of Loaded, -> (message, model) { model.with(characters: message.characters) }

  Update = from_router
end
