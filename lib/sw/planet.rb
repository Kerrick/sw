# frozen_string_literal: true

module Sw
  Planet = Data.define(:name, :population, :terrain, :climate, :surface_water, :diameter, :rotation_period, :orbital_period, :gravity, :residents) do
    def initialize(name:, population:, terrain:, climate:, surface_water:, diameter:, rotation_period:, orbital_period:, gravity:, residents: Collection.new([])) = super
  end
end
