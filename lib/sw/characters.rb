# frozen_string_literal: true

module Sw
  # The panel that lists every character by name.
  module Characters
    include Rooibos::Router

    Model = Data.define(:collection, :selected)

    Init = -> (characters:) {
      sorted = Collection.new(characters.sort_by(&:name))
      Model.new(collection: sorted, selected: sorted.first)
    }

    # Moves the selection one step by an operator (:+ or :-) and stops at either end.
    Select = -> (operator, model) {
      records = model.collection.to_a
      new_index = records.index(model.selected).public_send(operator, 1)
      model.with(selected: records[new_index.clamp(0, records.length - 1)])
    }

    receive_routed :move_down, -> (_, model) { Select.call(:+, model) }
    receive_routed :move_up, -> (_, model) { Select.call(:-, model) }

    receive_routed :move_first, -> (_, model) { model.with(selected: model.collection.first) }

    receive_routed :move_last, -> (_, model) { model.with(selected: model.collection.to_a.last) }

    Update = from_router

    View = -> (model, tui) {
      tui.list(
        items: model.collection.map(&:name),
        selected_index: model.collection.find_index(model.selected),
        highlight_style: tui.style(modifiers: [:reversed]),
        block: tui.block(title: "Characters", borders: [:all])
      )
    }
  end
end
