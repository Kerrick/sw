# frozen_string_literal: true

module Sw
  # The panel for the films a character appears in. It has no content yet.
  module Films
    View = -> (tui) { tui.block(title: "Films", borders: [:all]) }
  end
end
