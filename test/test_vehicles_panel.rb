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

  private def snowspeeder
    Sw::Vehicle.new(
      name: "Snowspeeder", model: "t-47 airspeeder", manufacturer: "Incom corporation",
      vehicle_class: "airspeeder", crew: Sw::Count.new("2"), passengers: Sw::Count.new("0")
    )
  end
end
