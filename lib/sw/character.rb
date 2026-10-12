# frozen_string_literal: true

module Sw
  Character = Data.define(:name, :vehicles) do
    def initialize(name:, vehicles: Collection.new([])) = super
  end
end
