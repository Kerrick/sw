# frozen_string_literal: true

module Sw
  # An ordered set of domain objects of one type. Whoever builds one makes it shareable, so the Mapper can fill
  # linked collections before it freezes them.
  Collection = Data.define(:items) do
    include Enumerable

    def each(&) = items.each(&)

    def empty? = items.empty?

    # Every cycle in the domain model runs through a Collection, so printing its items would walk the whole graph.
    def inspect = "#<#{self.class} #{[items.size, items.first&.class].compact.join(" ")}>"

    private :items
  end
end
