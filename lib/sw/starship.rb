# frozen_string_literal: true

module Sw
  Starship = Data.define(:name, :model, :manufacturer, :starship_class, :crew, :passengers, :pilots, :url) do
    include DomainObject

    def initialize(name:, model:, manufacturer:, starship_class:, crew:, passengers:, pilots: Collection.new([]), url: nil) = super
  end
end
