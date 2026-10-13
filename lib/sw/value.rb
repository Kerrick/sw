# frozen_string_literal: true

module Sw
  # One attribute of a domain object, as text, which may be "unknown". Every attribute that isn't an association or
  # a number is a Value, names included.
  Value = Data.define(:text) do
    include Comparable

    # Values sort by their text. Anything that isn't a Value doesn't compare, so == with a String is false.
    def <=>(other)
      text <=> other.text if other.is_a?(Value)
    end

    # Puts a comma before every three digits that run to the end.
    def to_s = text.gsub(/\d(?=(\d{3})+\z)/, '\0,')

    # A range like "30-165" isn't one number.
    def numeric? = text.match?(/\A[\d.,]+\z/)

    def unknown? = text == "unknown"

    # Dagobah's gravity says it in capitals.
    def not_applicable? = text.casecmp?("n/a")
  end
end
