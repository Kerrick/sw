# frozen_string_literal: true

module Sw
  # One field as the API writes it, which may be "unknown".
  Value = Data.define(:text) do
    include Comparable

    def <=>(other)
      text <=> other.text if other.is_a?(Value)
    end

    # Puts a comma before every three digits that run to the end.
    def to_s = text.gsub(/\d(?=(\d{3})+\z)/, '\0,')

    def unknown? = text == "unknown"
  end
end
