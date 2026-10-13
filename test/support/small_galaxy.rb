# frozen_string_literal: true

require "json"

# Ackbar, Han, and Luke, the first, middle, and last of the list, and every film one of them is in, linked as the API
# links them. For tests that need a panel to move through or films to light and dim: Luke is in all four films, Han
# misses one, and Ackbar is in only one. It slices the recorded responses in memory and drops the links to records
# left out, so the real Mapper builds it.
module SmallGalaxy
  CHARACTERS = ["Ackbar", "Han Solo", "Luke Skywalker"].freeze

  RECORDS = begin
    fixture_for = -> (name) { JSON.parse(File.read(File.join(FixtureServer::FIXTURES, "api/#{name}.json"))) }
    people = fixture_for.("people").select { |person| CHARACTERS.include?(person["name"]) }
    people_urls = people.map { |person| person["url"] }
    films = fixture_for.("films").select { |film| film["characters"].intersect?(people_urls) }
    urls = people_urls + films.map { |film| film["url"] }
    kept = -> (records) { records.map { |record| record.transform_values { |value| value.is_a?(Array) ? value & urls : value } } }
    Sw::Load::Mapper.new.records(people: kept.(people), vehicles: [], films: kept.(films))
  end

  private def ackbar = character("Ackbar")

  private def han = character("Han Solo")

  private def luke = character("Luke Skywalker")

  private def a_new_hope = film("A New Hope")

  private def revenge_of_the_sith = film("Revenge of the Sith")

  # Every film, in the order the API lists them: IV, V, VI, then III.
  private def films = RECORDS.fetch(:films)

  # The Characters panel as it opens, with Ackbar selected, or with another character selected.
  private def three_characters(selected: nil)
    panel = Sw::Characters::Init.(characters: Sw::Collection.new([luke, ackbar, han]))
    selected ? panel.with(selected:) : panel
  end

  private def character(name) = RECORDS.fetch(:characters).find { |character| character.name.to_s == name }

  private def film(title) = films.find { |film| film.title.to_s == title }
end
