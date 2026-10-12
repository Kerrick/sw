# frozen_string_literal: true

module Sw
  # An ordered, immutable set of records of one type.
  Collection = Data.define(:records) do
    include Enumerable

    def initialize(records:) = super(records: Ractor.make_shareable(records))

    def each(&) = records.each(&)

    private :records
  end
end
