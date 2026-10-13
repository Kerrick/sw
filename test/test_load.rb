# frozen_string_literal: true

require "test_helper"

class TestLoad < Minitest::Test
  include Rooibos::TestHelper

  KeepLastMessage = -> (message, model) do
    message.ctrl_c? ? [model, Rooibos::Command.exit] : message
  end

  def test_crawling_from_the_root_loads_all_82_characters
    assert_equal 82, finished.characters.count
  end

  def test_crawling_from_the_root_loads_all_39_vehicles
    assert_equal 39, finished.vehicles.count
  end

  def test_a_download_lands_in_the_users_cache_directory
    finished

    refute_empty Dir.glob("**/*.json", base: @cache_home)
  end

  def test_a_fresh_cache_loads_all_82_characters_without_the_network
    finished
    cached = delivered(unreachable_url)

    assert_equal "Sw::Load::Finished", cached.class.name
    assert_equal 82, cached.characters.count
  end

  def test_a_cache_downloaded_just_now_is_not_stale
    finished
    cached = delivered(unreachable_url)

    refute cached.stale, "Expected a cache downloaded just now to be fresh"
  end

  def test_a_cache_an_hour_short_of_a_week_old_is_not_stale
    finished
    an_hour_short_of_a_week_ago = Time.now - (((7 * 24) - 1) * 60 * 60)
    age_cache(an_hour_short_of_a_week_ago)
    cached = delivered(unreachable_url)

    refute cached.stale, "Expected a cache an hour short of a week old to be fresh"
  end

  def test_a_cache_a_week_and_an_hour_old_still_loads_but_knows_it_is_stale
    finished
    a_week_and_an_hour_ago = Time.now - (((7 * 24) + 1) * 60 * 60)
    age_cache(a_week_and_an_hour_ago)
    cached = delivered(unreachable_url)

    assert_equal "Sw::Load::Finished", cached.class.name
    assert_equal 82, cached.characters.count
    assert cached.stale, "Expected a cache a week and an hour old to be stale"
  end

  def test_a_reload_goes_to_the_network_even_when_the_cache_is_fresh
    finished
    reloaded = delivered(unreachable_url, reload: true)

    assert_equal "Sw::Load::Failed", reloaded.class.name
  end

  def test_a_refused_connection_fails_naming_the_address
    url = unreachable_url
    failed = delivered(url)

    assert_equal "Sw::Load::Failed", failed.class.name
    assert_includes failed.reason, URI(url).authority
  end

  def test_a_404_from_the_root_fails_naming_the_status_and_the_url
    url = "#{FIXTURE_SERVER.url}/missing"
    failed = delivered(url)

    assert_equal "Sw::Load::Failed", failed.class.name
    assert_includes failed.reason, "404"
    assert_includes failed.reason, url
  end

  def test_a_404_from_the_vehicles_collection_fails_naming_the_status_and_the_url
    failed = FIXTURE_SERVER.refusing("/api/vehicles") { delivered(FIXTURE_SERVER.url) }

    assert_equal "Sw::Load::Failed", failed.class.name
    assert_includes failed.reason, "404"
    assert_includes failed.reason, "#{FIXTURE_SERVER.url}/vehicles"
  end

  def test_a_dropped_connection_on_the_vehicles_collection_fails
    failed = FIXTURE_SERVER.dropping("/api/vehicles") { delivered(FIXTURE_SERVER.url) }

    assert_equal "Sw::Load::Failed", failed.class.name
    refute_empty failed.reason
  end

  def test_a_root_that_is_not_json_fails_naming_the_url
    failed = FIXTURE_SERVER.answering("/api", "<html>Bad Gateway</html>") { delivered(FIXTURE_SERVER.url) }

    assert_equal "Sw::Load::Failed", failed.class.name
    assert_includes failed.reason, FIXTURE_SERVER.url
  end

  def test_a_vehicles_collection_that_is_not_json_fails_naming_its_url
    failed = FIXTURE_SERVER.answering("/api/vehicles", "<html>Bad Gateway</html>") { delivered(FIXTURE_SERVER.url) }

    assert_equal "Sw::Load::Failed", failed.class.name
    assert_includes failed.reason, "#{FIXTURE_SERVER.url}/vehicles"
  end

  def test_a_vehicle_without_a_name_fails_the_download
    failed = FIXTURE_SERVER.answering("/api/vehicles", '[{"model": "Sand Crawler"}]') { delivered(FIXTURE_SERVER.url) }

    assert_equal "Sw::Load::Failed", failed.class.name
    assert_includes failed.reason, "name"
  end

  private def finished = delivered(FIXTURE_SERVER.url)

  private def delivered(url, **options)
    with_test_terminal do
      inject_sync
      inject_key(:ctrl_c)
      Rooibos::Runtime.run(model: :loading, view: ClearView, update: KeepLastMessage, command: Sw::Load.new(url:, **options))
    end
  end
end
