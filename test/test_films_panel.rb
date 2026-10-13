# frozen_string_literal: true

require "test_helper"

class TestFilmsPanel < Minitest::Test
  include ViewTestHelper
  include EntireGalaxy

  # The terminal is wide enough for the longest title to fit its column.
  def test_the_films_panel_lights_the_four_films_luke_is_in_and_dims_the_other_two
    with_rendered(Sw::Films::View.call(films, luke.films, tui), width: 160) do
      assert_text_style "The Phantom Menace", modifiers: [:bold, :dim]
      assert_text_style "Attack of the Clones", modifiers: [:bold, :dim]
      assert_text_style "Revenge of the Sith", modifiers: [:bold]
      assert_text_style "A New Hope", modifiers: [:bold]
      assert_text_style "The Empire Strikes Back", modifiers: [:bold]
      assert_text_style "Return of the Jedi", modifiers: [:bold]
    end
  end

  def test_the_films_panel_shows_episode_three_beneath_revenge_of_the_sith
    with_rendered(Sw::Films::View.call(films, luke.films, tui), width: 160) do
      _, title_row = text_position("Revenge of the Sith")

      refute_nil text_position("Episode III", line: title_row + 1)
    end
  end

  def test_the_films_panel_dims_episode_one_beneath_the_phantom_menace_which_luke_is_not_in
    with_rendered(Sw::Films::View.call(films, luke.films, tui), width: 160) do
      _, title_row = text_position("The Phantom Menace")

      assert_text_style "Episode I", line: title_row + 1, modifiers: [:dim]
    end
  end

  def test_the_films_panel_shows_episodes_one_through_six_from_left_to_right
    with_rendered(Sw::Films::View.call(films, luke.films, tui), width: 160) do
      episodes_one_through_six = ["The Phantom Menace", "Attack of the Clones", "Revenge of the Sith", "A New Hope", "The Empire Strikes Back", "Return of the Jedi"]
      columns = episodes_one_through_six.map { |title| text_position(title).first }

      assert_equal columns.sort, columns
    end
  end
end
