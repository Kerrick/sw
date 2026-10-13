# frozen_string_literal: true

module Sw
  Species = Data.define(:name, :classification, :designation, :average_height, :average_lifespan, :language, :people, :url) do
    include DomainObject

    def initialize(name:, classification:, designation:, average_height:, average_lifespan:, language:, people: Collection.new([]), url: nil) = super
  end
end
