# frozen_string_literal: true

module Sw
  Character = Data.define(:name, :homeworld, :vehicles, :starships, :films) do
    def initialize(name:, homeworld: nil, vehicles: Collection.new([]), starships: Collection.new([]), films: Collection.new([])) = super
  end
end
