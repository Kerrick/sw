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
require_relative "sw/root"

# The Star Wars Character Datapad.
module Sw
  API_URL = "https://swapi.info/api"
end
