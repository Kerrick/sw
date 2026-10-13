# frozen_string_literal: true

module Sw
  Character = Data.define(:name, :height, :mass, :hair_color, :skin_color, :eye_color, :birth_year, :gender, :homeworld, :species, :vehicles, :starships, :films) do
    def initialize(name:, height: Value.new("unknown"), mass: Value.new("unknown"), hair_color: Value.new("unknown"), skin_color: Value.new("unknown"), eye_color: Value.new("unknown"), birth_year: Value.new("unknown"), gender: Value.new("unknown"), homeworld: nil, species: Collection.new([]), vehicles: Collection.new([]), starships: Collection.new([]), films: Collection.new([])) = super
  end
end
