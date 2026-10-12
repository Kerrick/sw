# frozen_string_literal: true

module Sw
  Vehicle = Data.define(:name, :model, :manufacturer, :vehicle_class, :crew, :passengers, :pilots) do
    def initialize(name:, model:, manufacturer:, vehicle_class:, crew:, passengers:, pilots: Collection.new([])) = super
  end
end
