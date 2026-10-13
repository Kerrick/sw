# frozen_string_literal: true

module Sw
  Character = Data.define(:name, :homeworld, :species, :vehicles, :starships, :films) do
    def initialize(name:, homeworld: nil, species: Collection.new([]), vehicles: Collection.new([]), starships: Collection.new([]), films: Collection.new([])) = super
  end
end
