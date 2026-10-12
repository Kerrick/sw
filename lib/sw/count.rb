# frozen_string_literal: true

module Sw
  # How many people a vehicle carries, as the API writes it.
  Count = Data.define(:text) do
    # Puts a comma before every three digits that run to the end.
    def to_s = text.gsub(/\d(?=(\d{3})+\z)/, '\0,')
  end
end
