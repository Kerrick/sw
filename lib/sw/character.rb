# frozen_string_literal: true

module Sw
  Character = Data.define(:name, :vehicles, :films) do
    def initialize(name:, vehicles: Collection.new([]), films: Collection.new([])) = super
  end
end
