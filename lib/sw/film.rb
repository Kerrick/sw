# frozen_string_literal: true

module Sw
  Film = Data.define(:title, :episode_id, :characters) do
    def initialize(title:, episode_id:, characters: Collection.new([])) = super

    def episode = "Episode #{episode_id}"
  end
end
