# frozen_string_literal: true

module Sw
  # The panel that takes a query from the keyboard.
  module Search
    include Rooibos::Router

    Model = Data.define(:query)

    # Bubbled whenever the query changes, so the screen can narrow what it shows.
    class QueryChanged < Data.define(:query)
      include Rooibos::Message::Predicates
    end

    Init = -> { Ractor.make_shareable(Model.new(query: "")) }

    # Ctrl-U clears the line, as in a shell. Super-Backspace (Cmd or Win) arrives only from a terminal that reports Super.
    receive_events %i[ctrl_u super_backspace], -> (_, model) { model.with(query: "") }

    # A key that types one character. Ctrl and Alt chords are commands, not text, though Shift types capitals.
    Typed = -> (message, _) {
      message.respond_to?(:text?) && message.text? && message.code.length == 1 && !message.ctrl? && !message.alt?
    }

    receive Typed, -> (message, model) {
      query = "#{model.query}#{message.code}".freeze
      [model.with(query:), Rooibos::Command.bubble(QueryChanged.new(query:))]
    }

    receive_events :backspace, -> (_, model) { model.with(query: model.query.chop.freeze) }

    Update = from_router
  end
end
