# frozen_string_literal: true

module Sw
  Planet = Data.define(:name, :population, :terrain, :climate, :surface_water, :diameter, :rotation_period, :orbital_period, :gravity, :residents, :url) do
    include DomainObject

    def initialize(name:, population:, terrain:, climate:, surface_water:, diameter:, rotation_period:, orbital_period:, gravity:, residents: Collection.new([]), url: nil) = super
  end
end
