# frozen_string_literal: true

module Sw
  Film = Data.define(:title, :episode_id, :characters, :url) do
    include DomainObject

    def initialize(title:, episode_id:, characters: Collection.new([]), url: nil) = super

    def episode = "Episode #{episode_id}"
  end
end
