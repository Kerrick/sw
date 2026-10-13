# frozen_string_literal: true

module Sw
  Vehicle = Data.define(:name, :model, :manufacturer, :vehicle_class, :crew, :passengers, :pilots, :url) do
    include DomainObject

    def initialize(name:, model:, manufacturer:, vehicle_class:, crew:, passengers:, pilots: Collection.new([]), url: nil) = super
  end
end
