# frozen_string_literal: true

module Sw
  # An ordered set of domain objects of one type. Whoever builds one makes it shareable, so the Mapper can fill
  # linked collections before it freezes them.
  Collection = Data.define(:items) do
    include Enumerable

    def each(&) = items.each(&)

    private :items
  end
end
