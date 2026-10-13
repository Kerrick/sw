# frozen_string_literal: true

# Every character and film in the recorded responses, linked as the API links them and built by the real Mapper, for
# tests whose example is a real character's real films. Films come in the order the API lists them. A test includes
# this or SmallGalaxy, not both, since they share the names luke and films.
module EntireGalaxy
  RECORDS = begin
    fixture_for = -> (name) { JSON.parse(File.read(File.join(FixtureServer::FIXTURES, "api/#{name}.json"))) }
    Sw::Load::Mapper.new.records(people: fixture_for.("people"), vehicles: fixture_for.("vehicles"), starships: fixture_for.("starships"), films: fixture_for.("films"), planets: fixture_for.("planets"), species: fixture_for.("species"))
  end

  private def luke = RECORDS.fetch(:characters).find { |character| character.name.to_s == "Luke Skywalker" }

  private def films = RECORDS.fetch(:films)
end
