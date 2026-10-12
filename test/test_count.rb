# frozen_string_literal: true

require "test_helper"

class TestCount < Minitest::Test
  def test_the_snowspeeder_crew_of_two_reads_as_2
    assert_equal "2", Sw::Count.new("2").to_s
  end

  def test_the_executor_carries_38_000_passengers_with_a_thousands_separator
    assert_equal "38,000", Sw::Count.new("38000").to_s
  end

  def test_the_death_star_passengers_already_read_as_843_342
    assert_equal "843,342", Sw::Count.new("843,342").to_s
  end

  def test_the_cr90_corvette_crew_reads_as_the_range_30_165
    assert_equal "30-165", Sw::Count.new("30-165").to_s
  end

  def test_the_star_destroyer_passengers_read_as_not_applicable
    assert_equal "n/a", Sw::Count.new("n/a").to_s
  end
end
