# frozen_string_literal: true

module Sw
  # The panel that lists every character by name.
  module Characters
    Model = Data.define(:collection, :selected)

    Init = -> (characters:) {
      sorted = Collection.new(characters.sort_by(&:name))
      Model.new(collection: sorted, selected: sorted.first)
    }

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
