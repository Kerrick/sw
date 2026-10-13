# frozen_string_literal: true

require "etcetera"
require "fileutils"

module Sw
  # Crawls the API from its root and delivers what it finds in one message.
  class Load < Data.define(:url)
    include Rooibos::Command::Custom

    Command = Rooibos::Command

    # Where the platform keeps this app's cache: ~/Library/Caches/com.kerricklong.sw on macOS.
    CACHE = Etcetera::AppStrategy::AppStrategyArgs.new(top_level_domain: "com", author: "kerricklong", app_name: "sw")

    # The message Load sends when the whole dataset has arrived.
    class Finished < Data.define(:characters, :vehicles, :starships, :films, :planets, :species)
      include Rooibos::Message::Predicates
    end

    # The message Load sends when the download fails.
    class Failed < Data.define(:reason)
      include Rooibos::Message::Predicates
    end

    def call(out, token)
      out.put(catch(:failed) { download(out, token) })
    rescue => e
      out.put(failure(e.message))
    end

    private def download(out, token)
      cached = recall
      root = cached ? cached.fetch(:root) : fetch_root(out, token).body
      links = parse(url) { mapper.links(root) }
      bodies = cached || fetch_collections(out, token, links)
      parsed = Mapper::COLLECTIONS.keys.to_h { |name| [name, parse(links.fetch(name)) { mapper.parse(bodies.fetch(name)) }] }
      finished = Finished.new(**mapper.records(**parsed))
      keep(root:, **bodies) unless cached
      finished
    end

    private def fetch_root(out, token)
      root = out.source(Command.http(:get, url, :root), token)
      refuse(root, url) unless root.success?
      root
    end

    private def fetch_collections(out, token, links)
      fetches = links.map { |name, link| Command.http(:get, link, name) }
      responses = out.source(Command.all(:collections, fetches), token).results
      refused = responses.find { |response| !response.success? }
      refuse(refused, links.fetch(refused.envelope)) if refused
      responses.to_h { |response| [response.envelope, response.body] }
    end

    # Ends the download with a Failed, from anywhere inside it.
    private def refuse(response, from)
      throw :failed, failure(response.error || "HTTP #{response.status} from #{from}")
    end

    private def parse(from)
      yield
    rescue JSON::ParserError
      throw :failed, failure("Couldn't read the response from #{from}")
    end

    # Keeps the raw responses, never the domain objects, so a fix to the Mapper applies to a cache already on disk. Only a
    # download that mapped cleanly is kept, so a bad response never replaces a good one.
    private def keep(bodies)
      FileUtils.mkdir_p(cache_directory)
      bodies.each { |name, body| File.binwrite(cache_directory.join("#{name}.json"), body) }
    end

    # The raw responses #keep left, by name, or nil unless every one is there.
    private def recall
      files = [:root, *Mapper::COLLECTIONS.keys].to_h { |name| [name, cache_directory.join("#{name}.json")] }
      files.transform_values(&:binread) if files.values.all?(&:file?)
    end

    private def cache_directory = Etcetera::AppStrategy.choose_native_strategy(CACHE).cache_dir

    private def failure(reason) = Failed.new(reason: reason.freeze)

    private def mapper = Mapper.new
  end
end
