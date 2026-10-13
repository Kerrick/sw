# frozen_string_literal: true

require "test_helper"

class TestLoadMapper < Minitest::Test
  PEOPLE = File.read(File.join(FixtureServer::FIXTURES, "api/people.json")).freeze
  VEHICLES = File.read(File.join(FixtureServer::FIXTURES, "api/vehicles.json")).freeze
  FILMS = File.read(File.join(FixtureServer::FIXTURES, "api/films.json")).freeze
  STARSHIPS = File.read(File.join(FixtureServer::FIXTURES, "api/starships.json")).freeze
  PLANETS = File.read(File.join(FixtureServer::FIXTURES, "api/planets.json")).freeze
  SPECIES = File.read(File.join(FixtureServer::FIXTURES, "api/species.json")).freeze

  def test_the_first_person_is_luke_skywalker
    assert_equal "Luke Skywalker", records.fetch(:characters).first.name.to_s
  end

  def test_all_82_people_become_characters
    assert_equal 82, records.fetch(:characters).count
  end

  def test_people_map_to_a_collection
    assert_kind_of Sw::Collection, records.fetch(:characters)
  end

  def test_luke_pilots_the_snowspeeder_and_the_imperial_speeder_bike
    luke = records.fetch(:characters).first

    assert_equal ["Snowspeeder", "Imperial Speeder Bike"], luke.vehicles.map { |vehicle| vehicle.name.to_s }
  end

  def test_luke_pilots_the_x_wing_and_the_imperial_shuttle
    luke = records.fetch(:characters).first

    assert_equal ["X-wing", "Imperial shuttle"], luke.starships.map { |starship| starship.name.to_s }
  end

  def test_luke_is_from_tatooine
    luke = records.fetch(:characters).first

    assert_equal "Tatooine", luke.homeworld.name.to_s
  end

  def test_ackbar_is_a_mon_calamari
    ackbar = records.fetch(:characters).find { |character| character.name.to_s == "Ackbar" }

    assert_equal ["Mon Calamari"], ackbar.species.map { |species| species.name.to_s }
  end

  def test_polis_massa_has_an_unknown_diameter_rather_than_none
    polis_massa = records.fetch(:planets).find { |planet| planet.name.to_s == "Polis Massa" }

    assert_predicate polis_massa.diameter, :unknown?
  end

  def test_tund_is_known_to_have_no_population
    tund = records.fetch(:planets).find { |planet| planet.name.to_s == "Tund" }

    assert_equal Sw::Value.new("0"), tund.population
  end

  def test_yodas_unknown_homeworld_turns_and_orbits_in_an_unknown_time_rather_than_none
    yodas_homeworld = records.fetch(:characters).find { |character| character.name.to_s == "Yoda" }.homeworld

    assert_predicate yodas_homeworld.rotation_period, :unknown?
    assert_predicate yodas_homeworld.orbital_period, :unknown?
  end

  def test_the_snowspeeder_is_piloted_by_luke_skywalker_and_wedge_antilles
    snowspeeder = records.fetch(:characters).first.vehicles.first

    assert_equal ["Luke Skywalker", "Wedge Antilles"], snowspeeder.pilots.map { |pilot| pilot.name.to_s }
  end

  def test_the_x_wing_is_piloted_by_luke_biggs_wedge_and_porkins
    x_wing = records.fetch(:characters).first.starships.first

    assert_equal ["Luke Skywalker", "Biggs Darklighter", "Wedge Antilles", "Jek Tono Porkins"], x_wing.pilots.map { |pilot| pilot.name.to_s }
  end

  def test_every_pilot_and_every_piloted_vehicle_list_each_other
    characters, vehicles = records.values_at(:characters, :vehicles)
    unlisted_vehicles = characters.flat_map do |character|
      character.vehicles.reject { |vehicle| vehicle.pilots.include?(character) }.map { |vehicle| "#{vehicle.name} omits #{character.name}" }
    end
    unlisted_pilots = vehicles.flat_map do |vehicle|
      vehicle.pilots.reject { |pilot| pilot.vehicles.include?(vehicle) }.map { |pilot| "#{pilot.name} omits #{vehicle.name}" }
    end

    assert_empty unlisted_vehicles + unlisted_pilots
  end

  def test_every_pilot_and_every_piloted_starship_list_each_other
    characters, starships = records.values_at(:characters, :starships)
    unlisted_starships = characters.flat_map do |character|
      character.starships.reject { |starship| starship.pilots.include?(character) }.map { |starship| "#{starship.name} omits #{character.name}" }
    end
    unlisted_pilots = starships.flat_map do |starship|
      starship.pilots.reject { |pilot| pilot.starships.include?(starship) }.map { |pilot| "#{pilot.name} omits #{starship.name}" }
    end

    assert_empty unlisted_starships + unlisted_pilots
  end

  def test_every_film_and_every_character_in_it_list_each_other
    characters, films = records.values_at(:characters, :films)
    unlisted_films = characters.flat_map do |character|
      character.films.reject { |film| film.characters.include?(character) }.map { |film| "#{film.title} omits #{character.name}" }
    end
    unlisted_characters = films.flat_map do |film|
      film.characters.reject { |character| character.films.include?(film) }.map { |character| "#{character.name} omits #{film.title}" }
    end

    assert_empty unlisted_films + unlisted_characters
  end

  def test_every_character_and_their_homeworld_list_each_other
    characters, planets = records.values_at(:characters, :planets)
    unlisted_residents = characters.reject { |character| character.homeworld.residents.include?(character) }.map do |character|
      "#{character.homeworld.name} omits #{character.name}"
    end
    misplaced_residents = planets.flat_map do |planet|
      planet.residents.reject { |resident| resident.homeworld == planet }.map { |resident| "#{resident.name} isn't from #{planet.name}" }
    end

    assert_empty unlisted_residents + misplaced_residents
  end

  def test_the_human_species_doesnt_list_luke_either
    luke = records.fetch(:characters).first
    human = records.fetch(:species).find { |species| species.name.to_s == "Human" }

    assert_empty luke.species
    refute_includes human.people.map { |character| character.name.to_s }, "Luke Skywalker"
  end

  def test_every_character_and_their_species_list_each_other
    characters, species = records.values_at(:characters, :species)
    unlisted_members = characters.flat_map do |character|
      character.species.reject { |kind| kind.people.include?(character) }.map { |kind| "#{kind.name} omits #{character.name}" }
    end
    unlisted_species = species.flat_map do |kind|
      kind.people.reject { |character| character.species.include?(kind) }.map { |character| "#{character.name} omits #{kind.name}" }
    end

    assert_empty unlisted_members + unlisted_species
  end

  def test_the_snowspeeder_is_an_incom_t47_airspeeder_for_a_crew_of_two_and_no_passengers
    snowspeeder = records.fetch(:characters).first.vehicles.first

    assert_equal(
      {
        model: Sw::Value.new("t-47 airspeeder"),
        manufacturer: Sw::Value.new("Incom corporation"),
        vehicle_class: Sw::Value.new("airspeeder"),
        crew: Sw::Value.new("2"),
        passengers: Sw::Value.new("0"),
      },
      snowspeeder.to_h.slice(:model, :manufacturer, :vehicle_class, :crew, :passengers)
    )
  end

  def test_the_emergency_firespeeder_manufacturer_is_unknown
    emergency_firespeeder = records.fetch(:vehicles).find { |vehicle| vehicle.name.to_s == "Emergency Firespeeder" }

    assert_predicate emergency_firespeeder.manufacturer, :unknown?
  end

  def test_the_linked_records_can_be_shared_between_ractors
    assert Ractor.shareable?(records)
  end

  def test_luke_appears_in_a_new_hope_the_empire_strikes_back_return_of_the_jedi_and_revenge_of_the_sith
    luke = records.fetch(:characters).first

    assert_equal ["A New Hope", "The Empire Strikes Back", "Return of the Jedi", "Revenge of the Sith"], luke.films.map { |film| film.title.to_s }
  end

  def test_a_new_hope_features_luke_threepio_artoo_vader_and_leia_among_its_18_characters
    a_new_hope = records.fetch(:films).find { |film| film.title.to_s == "A New Hope" }

    assert_equal ["Luke Skywalker", "C-3PO", "R2-D2", "Darth Vader", "Leia Organa"], a_new_hope.characters.first(5).map { |character| character.name.to_s }
    assert_equal 18, a_new_hope.characters.count
  end

  def test_a_new_hope_is_episode_iv
    a_new_hope = records.fetch(:films).find { |film| film.title.to_s == "A New Hope" }

    assert_equal "IV", a_new_hope.episode_id.to_s
  end

  def test_the_first_vehicle_is_the_sand_crawler
    assert_equal "Sand Crawler", records.fetch(:vehicles).first.name.to_s
  end

  private def records
    mapper = Sw::Load::Mapper.new
    mapper.records(people: mapper.parse(PEOPLE), vehicles: mapper.parse(VEHICLES), films: mapper.parse(FILMS), starships: mapper.parse(STARSHIPS), planets: mapper.parse(PLANETS), species: mapper.parse(SPECIES))
  end
end
