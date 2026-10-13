# frozen_string_literal: true

require "test_helper"

class TestFilm < Minitest::Test
  include EntireGalaxy

  def test_revenge_of_the_sith_calls_itself_episode_iii
    revenge_of_the_sith = films.find { |film| film.title.to_s == "Revenge of the Sith" }

    assert_equal "Episode III", revenge_of_the_sith.episode
  end

  def test_a_new_hope_calls_itself_episode_iv
    a_new_hope = films.find { |film| film.title.to_s == "A New Hope" }

    assert_equal "Episode IV", a_new_hope.episode
  end
end
