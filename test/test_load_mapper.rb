# frozen_string_literal: true

require "test_helper"

class TestLoadMapper < Minitest::Test
  PEOPLE = File.read(File.join(FixtureServer::FIXTURES, "api/people.json")).freeze
  VEHICLES = File.read(File.join(FixtureServer::FIXTURES, "api/vehicles.json")).freeze

  def test_the_first_person_is_luke_skywalker
    mapper = Sw::Load::Mapper.new

    assert_equal "Luke Skywalker", mapper.characters(PEOPLE).first.name
  end

  def test_all_82_people_become_characters
    mapper = Sw::Load::Mapper.new

    assert_equal 82, mapper.characters(PEOPLE).count
  end

  def test_people_map_to_a_collection
    mapper = Sw::Load::Mapper.new

    assert_kind_of Sw::Collection, mapper.characters(PEOPLE)
  end

  def test_the_first_vehicle_is_the_sand_crawler
    mapper = Sw::Load::Mapper.new

    assert_equal "Sand Crawler", mapper.vehicles(VEHICLES).first.name
  end
end
