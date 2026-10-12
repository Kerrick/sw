# frozen_string_literal: true

require "test_helper"

class TestLoadMapper < Minitest::Test
  PEOPLE = File.read(File.join(FixtureServer::FIXTURES, "api/people.json")).freeze
  VEHICLES = File.read(File.join(FixtureServer::FIXTURES, "api/vehicles.json")).freeze

  def test_the_first_person_is_luke_skywalker
    assert_equal "Luke Skywalker", records.fetch(:characters).first.name
  end

  def test_all_82_people_become_characters
    assert_equal 82, records.fetch(:characters).count
  end

  def test_people_map_to_a_collection
    assert_kind_of Sw::Collection, records.fetch(:characters)
  end

  def test_luke_pilots_the_snowspeeder_and_the_imperial_speeder_bike
    luke = records.fetch(:characters).first

    assert_equal ["Snowspeeder", "Imperial Speeder Bike"], luke.vehicles.map(&:name)
  end

  def test_the_snowspeeder_is_an_incom_t47_airspeeder_for_a_crew_of_two_and_no_passengers
    snowspeeder = records.fetch(:characters).first.vehicles.first

    assert_equal(
      { model: "t-47 airspeeder", manufacturer: "Incom corporation", vehicle_class: "airspeeder", crew: Sw::Count.new("2"), passengers: Sw::Count.new("0") },
      snowspeeder.to_h.slice(:model, :manufacturer, :vehicle_class, :crew, :passengers)
    )
  end

  def test_the_linked_records_can_be_shared_between_ractors
    assert Ractor.shareable?(records)
  end

  def test_the_first_vehicle_is_the_sand_crawler
    assert_equal "Sand Crawler", records.fetch(:vehicles).first.name
  end

  private def records
    mapper = Sw::Load::Mapper.new
    mapper.records(people: mapper.parse(PEOPLE), vehicles: mapper.parse(VEHICLES))
  end
end
