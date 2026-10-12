# frozen_string_literal: true

module Sw
  # The message Load sends when the whole dataset has arrived.
  class Loaded < Data.define(:characters, :vehicles)
    include Rooibos::Message::Predicates
  end
end
