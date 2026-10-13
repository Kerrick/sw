# frozen_string_literal: true

require "json"
require "roman"

module Sw
  class Load
    # Maps the API's records to domain objects, by Metadata Mapping: COLLECTIONS names each collection's record
    # class, and each class's Data members name the API fields it reads. Every array is a list of links and becomes
    # a Collection of records; a LINKS field is one link and becomes the record itself; every other field becomes a
    # Value, or a RomanNumeral where NUMERALS says so.
    class Mapper
      # Each API collection, with the name the app uses for it and the class of its records. A new collection needs
      # only an entry here and a Data class. A record must exist before another can link to it by a LINKS field, so
      # collections map in this order: planets before people.
      COLLECTIONS = {
        planets: [:planets, Planet],
        people: [:characters, Character],
        vehicles: [:vehicles, Vehicle],
        starships: [:starships, Starship],
        films: [:films, Film],
      }.freeze

      # Which members the API sends as one link rather than a list of them.
      LINKS = %i[homeworld].freeze

      # Which members the API sends as numbers but that represent Roman numerals.
      NUMERALS = %i[episode_id].freeze

      # Which members can't be zero, so the API's "0" there means it doesn't know. Every planet has a size, turns, and
      # orbits.
      NEVER_ZERO = %i[diameter rotation_period orbital_period].freeze

      def links(root)
        JSON.parse(root, freeze: true).transform_keys(&:to_sym)
      end

      def parse(body) = JSON.parse(body)

      # Maps every collection at once, so each record can hold the records it links to.
      def records(**collections) = Mapping.new.call(collections)

      # One run of #records. It remembers each record by its URL, and each link to fill once every record exists,
      # then freezes the whole graph. Records hold each other directly, with no IDs, and the index of URLs is gone
      # when the run ends.
      class Mapping
        def initialize
          @by_url = {}
          @links = []
        end

        def call(collections)
          ordered = collections.sort_by { |api_name, _| COLLECTIONS.keys.index(api_name) }
          mapped = ordered.to_h { |api_name, json_records| collection(api_name, json_records) }
          link
          Ractor.make_shareable(mapped)
        end

        private def collection(api_name, json_records)
          name, type = COLLECTIONS.fetch(api_name)
          [name, Collection.new(json_records.map { |json| record(type, json) })]
        end

        # A record takes the API's field of the same name for each of its members.
        private def record(type, json)
          record = type.new(**type.members.to_h { |member| [member, field(member, json.fetch(member.to_s))] })
          @by_url[json.fetch("url")] = record
        end

        # Every array in the API is a list of links, a LINKS field is one link, and a NUMERALS field is a RomanNumeral.
        # Every other field is a Value, which may be unknown, as a NEVER_ZERO field's "0" is.
        private def field(member, value)
          return links_to(value) if value.is_a?(Array)
          return @by_url.fetch(value) if LINKS.include?(member)
          return RomanNumeral.new(value) if NUMERALS.include?(member)
          return Value.new("unknown") if NEVER_ZERO.include?(member) && value == "0"

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
