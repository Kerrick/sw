# frozen_string_literal: true

module Sw
  # One field as the API writes it, which may be "unknown". Every field of a record that isn't a link is a Value,
  # names included.
  Value = Data.define(:text) do
    include Comparable

    # Values sort by their text. Anything that isn't a Value doesn't compare, so == with a String is false.
    def <=>(other)
      text <=> other.text if other.is_a?(Value)
    end

    # Puts a comma before every three digits that run to the end.
    def to_s = text.gsub(/\d(?=(\d{3})+\z)/, '\0,')

    def unknown? = text == "unknown"
  end
end
