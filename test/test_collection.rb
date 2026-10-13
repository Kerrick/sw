# frozen_string_literal: true

require "test_helper"

class TestCollection < Minitest::Test
  def test_it_enumerates_its_records_in_order
    luke = Sw::Character.new(name: Sw::Value.new("Luke Skywalker"))
    leia = Sw::Character.new(name: Sw::Value.new("Leia Organa"))

    assert_equal ["Luke Skywalker", "Leia Organa"], Sw::Collection.new([luke, leia]).map { |character| character.name.to_s }
  end

  def test_luke_belongs_to_no_species
    lukes_species = EntireGalaxy::RECORDS.fetch(:characters).first.species

    assert_empty lukes_species
  end
end
