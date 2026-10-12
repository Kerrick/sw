# frozen_string_literal: true

require "json"

module Sw
  class Load
    # Maps the API's records to domain objects.
    class Mapper
      def links(root)
        JSON.parse(root, freeze: true).transform_keys(&:to_sym)
      end

      def characters(people)
        collection(people) { |person| Character.new(name: person.fetch("name")) }
      end

      def vehicles(vehicles)
        collection(vehicles) { |vehicle| Vehicle.new(name: vehicle.fetch("name")) }
      end

      private def collection(body, &)
        Collection.new(JSON.parse(body).map(&))
      end
    end
  end
end
