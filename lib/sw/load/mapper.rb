# frozen_string_literal: true

require "json"

module Sw
  class Load
    # Maps the API's records to domain objects.
    class Mapper
      # Each API collection, with the name the app uses for it and the class of its records.
      COLLECTIONS = { people: [:characters, Character], vehicles: [:vehicles, Vehicle] }.freeze

      def links(root)
        JSON.parse(root, freeze: true).transform_keys(&:to_sym)
      end

      def parse(body) = JSON.parse(body)

      # Maps every collection at once, so each record can hold the records it links to.
      def records(**collections) = Mapping.new.call(collections)

      # One run of #records. It remembers each record by its URL, and each link to fill once every record exists.
      class Mapping
        def initialize
          @by_url = {}
          @links = []
        end

        def call(collections)
          mapped = collections.to_h { |api_name, json_records| collection(api_name, json_records) }
          link
          Ractor.make_shareable(mapped)
        end

        private def collection(api_name, json_records)
          name, type = COLLECTIONS.fetch(api_name)
          [name, Collection.new(json_records.map { |json| record(type, json) })]
        end

        # A record takes the API's field of the same name for each of its members.
        private def record(type, json)
          record = type.new(**type.members.to_h { |member| [member, field(json.fetch(member.to_s))] })
          @by_url[json.fetch("url")] = record
        end

        # Every array in the API is a list of links. Every other field is a Value, which may be unknown.
        private def field(value)
          return links_to(value) if value.is_a?(Array)

          Value.new(value)
        end

        # A Collection of the records at the URLs, filled by #link once every record exists.
        private def links_to(urls)
          records = []
          @links << [records, urls]
          Collection.new(records)
        end

        private def link
          @links.each { |records, urls| records.concat(urls.map { |url| @by_url.fetch(url) }) }
        end
      end
      private_constant :Mapping
    end
  end
end
