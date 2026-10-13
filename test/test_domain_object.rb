# frozen_string_literal: true

require "test_helper"

class TestDomainObject < Minitest::Test
  include SmallGalaxy

  def test_luke_inspects_as_a_character_named_luke_skywalker_without_his_whole_galaxy
    assert_equal "#<Sw::Character Luke Skywalker>", luke.inspect
  end

  def test_a_new_hope_inspects_by_its_title
    assert_equal "#<Sw::Film A New Hope>", a_new_hope.inspect
  end
end
