# frozen_string_literal: true

module Sw
  # An ordered set of records of one type. Whoever builds one makes it shareable, so the Mapper can fill linked
  # collections before it freezes them.
  Collection = Data.define(:records) do
    include Enumerable

    def each(&) = records.each(&)

    private :records
  end
end
