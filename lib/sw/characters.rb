# frozen_string_literal: true

module Sw
  # The panel that lists every character by name.
  module Characters
    include Rooibos::Router

    Model = Data.define(:collection, :selected, :query) do
      def initialize(collection:, selected:, query: "") = super

      def matches
        Collection.new(collection.select { |character| character.name.to_s.downcase.include?(query.downcase) })
      end
    end

    Init = -> (characters:, query: "") {
      sorted = Collection.new(characters.sort_by(&:name))
      model = Model.new(collection: sorted, selected: nil, query:)
      Ractor.make_shareable(model.with(selected: model.matches.first))
    }

    # Moves the selection one step by an operator (:+ or :-) and stops at either end.
    Select = -> (operator, model) {
      return model unless model.selected

      shown = model.matches.to_a
      new_index = shown.index(model.selected).public_send(operator, 1)
      model.with(selected: shown[new_index.clamp(0, shown.length - 1)])
    }

    receive_routed :move_down, -> (_, model) { Select.call(:+, model) }
    receive_routed :move_up, -> (_, model) { Select.call(:-, model) }

    receive_routed :filter, -> (message, model) {
      matches = model.with(query: message.event.query).matches
      model.with(query: message.event.query, selected: matches.include?(model.selected) ? model.selected : matches.first)
    }

    receive_routed :move_first, -> (_, model) { model.with(selected: model.matches.first) }

    receive_routed :move_last, -> (_, model) { model.with(selected: model.matches.to_a.last) }

    # What the status line shows for this panel. The arrow and Home/End keys work too, but aren't listed.
    Keys = [["k/j", "Prev/Next"], ["g/G", "First/Last"]].freeze

    Update = from_router

    # What the panel says, above the query, when no character matches it.
    EMPTY = "No match for"

    Empty = -> (query, tui) {
      tui.paragraph(
        text: [
          tui.text_line(spans: [tui.text_span(content: EMPTY, style: tui.style(modifiers: [:dim]))]),
          tui.text_line(spans: [tui.text_span(content: query, style: tui.style(fg: :yellow, modifiers: [:dim]))]),
        ],
        wrap: true
      )
    }

    # A List takes only strings and text, unlike a block title, so each name's Value becomes a String here.
    View = -> (model, tui, number:, focused: false) {
      matches = model.matches
      block = tui.block(title: "[#{number}] Characters", borders: [:all], border_style: tui.style(fg: (:green if focused)))
      return block.with(children: [Empty.(model.query, tui)]) if matches.none?

      tui.list(
        items: matches.map { |character| character.name.to_s },
        selected_index: matches.find_index(model.selected),
        highlight_style: tui.style(modifiers: [:reversed]),
        block:
      )
    }
  end
end
