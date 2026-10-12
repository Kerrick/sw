# frozen_string_literal: true

# Ackbar, Han, and Luke, the first, middle, and last of the list, for tests that need a panel to move through.
module ThreeCharacters
  private def ackbar = @ackbar ||= Sw::Character.new(name: Sw::Value.new("Ackbar"))

  private def han = @han ||= Sw::Character.new(name: Sw::Value.new("Han Solo"))

  private def luke = @luke ||= Sw::Character.new(name: Sw::Value.new("Luke Skywalker"))

  # The Characters panel as it opens, with Ackbar selected, or with another character selected.
  private def three_characters(selected: nil)
    panel = Sw::Characters::Init.(characters: Sw::Collection.new([luke, ackbar, han]))
    selected ? panel.with(selected:) : panel
  end
end
