# frozen_string_literal: true

module Sw
  Starship = Data.define(:name, :model, :manufacturer, :starship_class, :crew, :passengers, :pilots) do
    def initialize(name:, model:, manufacturer:, starship_class:, crew:, passengers:, pilots: Collection.new([])) = super
  end
end
