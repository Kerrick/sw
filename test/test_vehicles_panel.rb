# frozen_string_literal: true

require "test_helper"

class TestVehiclesPanel < Minitest::Test
  include ViewTestHelper

  def test_the_snowspeeder_is_named_in_bold
    with_rendered(Sw::Vehicles::View.call(Sw::Collection.new([snowspeeder]), tui)) do
      y = buffer_content.index { |line| line.include?("Snowspeeder") }

      refute_nil y, "Expected Snowspeeder on screen"
      assert_bold(buffer_content[y].index("Snowspeeder"), y)
    end
  end

  def test_the_snowspeeder_is_shown_as_an_airspeeder
    with_rendered(Sw::Vehicles::View.call(Sw::Collection.new([snowspeeder]), tui)) do
      assert_includes buffer_content.join("\n"), "airspeeder"
    end
  end

  def test_the_sand_crawler_carries_a_crew_of_46_and_30_passengers
    with_rendered(Sw::Vehicles::View.call(Sw::Collection.new([sand_crawler]), tui)) do
      screen = buffer_content.join("\n")

      assert_includes screen, "46"
      assert_includes screen, "30"
    end
  end

  def test_the_sand_crawler_is_a_digger_crawler_by_corellia_mining_corporation
    with_rendered(Sw::Vehicles::View.call(Sw::Collection.new([sand_crawler]), tui)) do
      screen = buffer_content.join("\n")

      assert_includes screen, "Digger Crawler"
      assert_includes screen, "Corellia Mining Corporation"
    end
  end

  def test_the_emergency_firespeeder_passengers_are_dimmed_as_unknown
    with_rendered(Sw::Vehicles::View.call(Sw::Collection.new([emergency_firespeeder]), tui)) do
      y = buffer_content.index { |line| line.include?("unknown") && !line.include?("Fire suppression speeder") }

      refute_nil y, "Expected the unknown passengers on screen"
      assert_dim(buffer_content[y].index("unknown"), y)
    end
  end

  private def emergency_firespeeder
    Sw::Vehicle.new(
      name: Sw::Value.new("Emergency Firespeeder"), model: Sw::Value.new("Fire suppression speeder"), manufacturer: Sw::Value.new("unknown"),
      vehicle_class: Sw::Value.new("fire suppression ship"), crew: Sw::Value.new("2"), passengers: Sw::Value.new("unknown")
    )
  end

  private def sand_crawler
    Sw::Vehicle.new(
      name: Sw::Value.new("Sand Crawler"), model: Sw::Value.new("Digger Crawler"), manufacturer: Sw::Value.new("Corellia Mining Corporation"),
      vehicle_class: Sw::Value.new("wheeled"), crew: Sw::Value.new("46"), passengers: Sw::Value.new("30")
    )
  end

  private def snowspeeder
    Sw::Vehicle.new(
      name: Sw::Value.new("Snowspeeder"), model: Sw::Value.new("t-47 airspeeder"), manufacturer: Sw::Value.new("Incom corporation"),
      vehicle_class: Sw::Value.new("airspeeder"), crew: Sw::Value.new("2"), passengers: Sw::Value.new("0")
    )
  end
end
