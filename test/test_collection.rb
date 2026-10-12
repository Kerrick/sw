# frozen_string_literal: true

require "test_helper"

class TestCollection < Minitest::Test
  def test_it_enumerates_its_records_in_order
    luke = Sw::Character.new(name: "Luke Skywalker")
    leia = Sw::Character.new(name: "Leia Organa")

    assert_equal ["Luke Skywalker", "Leia Organa"], Sw::Collection.new([luke, leia]).map(&:name)
  end

  def test_it_is_shareable_between_ractors_even_from_mutable_records
    luke = Sw::Character.new(name: +"Luke Skywalker")

    assert Ractor.shareable?(Sw::Collection.new([luke]))
  end
end
