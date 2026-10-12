# frozen_string_literal: true

require "test_helper"

class TestValue < Minitest::Test
  def test_the_snowspeeder_crew_of_two_reads_as_2
    snowspeeder_crew = Sw::Value.new("2")

    assert_equal "2", snowspeeder_crew.to_s
  end

  def test_the_executor_carries_38_000_passengers_with_a_thousands_separator
    executor_passengers = Sw::Value.new("38000")

    assert_equal "38,000", executor_passengers.to_s
  end

  def test_the_death_star_passengers_already_read_as_843_342
    death_star_passengers = Sw::Value.new("843,342")

    assert_equal "843,342", death_star_passengers.to_s
  end

  def test_the_cr90_corvette_crew_reads_as_the_range_30_165
    cr90_corvette_crew = Sw::Value.new("30-165")

    assert_equal "30-165", cr90_corvette_crew.to_s
  end

  def test_the_emergency_firespeeder_passenger_count_is_unknown
    emergency_firespeeder_passengers = Sw::Value.new("unknown")

    assert_predicate emergency_firespeeder_passengers, :unknown?
  end

  def test_the_snowspeeder_crew_of_two_is_known
    snowspeeder_crew = Sw::Value.new("2")

    refute_predicate snowspeeder_crew, :unknown?
  end

  def test_ackbar_sorts_before_luke_skywalker
    ackbar = Sw::Value.new("Ackbar")
    luke = Sw::Value.new("Luke Skywalker")

    assert_operator ackbar, :<, luke
  end

  def test_the_star_destroyer_passengers_read_as_not_applicable
    star_destroyer_passengers = Sw::Value.new("n/a")

    assert_equal "n/a", star_destroyer_passengers.to_s
  end
end
