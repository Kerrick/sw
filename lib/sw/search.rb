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

    Change = -> (model, query) {
      query = query.freeze
      [model.with(query:), Rooibos::Command.bubble(QueryChanged.new(query:))]
    }
    private_constant :Change

    # Ctrl-U clears the line, as in a shell. Super-Backspace (Cmd or Win) arrives only from a terminal that reports Super.
    receive_events %i[ctrl_u super_backspace], -> (_, model) { Change.(model, "") }

    receive_routed :clear, -> (_, model) { Change.(model, "") }

    # Ctrl and Alt chords are commands, not text, though Shift types capitals.
    Typed = -> (message, _) {
      message.respond_to?(:text?) && message.text? && message.code.length == 1 && !message.ctrl? && !message.alt?
    }

    receive Typed, -> (message, model) { Change.(model, "#{model.query}#{message.code}") }

    receive_instances_of RatatuiRuby::Event::Paste, -> (message, model) { Change.(model, message.content.chomp) }

    receive_events :backspace, -> (_, model) { Change.(model, model.query.chop) }

    ClearKey = ["esc", "Clear search"].freeze

    Keys = [["enter", "Finish search"], ClearKey].freeze

    Update = from_router

    View = -> (model, tui, focused:, number:) {
      # RatatuiRuby drops a tui.cursor nested anywhere in a View, so the cursor is a span.
      cursor = (tui.text_span(content: "_", style: tui.style(modifiers: [:slow_blink])) if focused)
      text = tui.text_line(spans: [tui.text_span(content: model.query), *cursor])
      tui.paragraph(text:, block: tui.block(title: "[#{number}] Search", borders: [:all], border_style: tui.style(fg: (:green if focused))))
    }
  end
end
