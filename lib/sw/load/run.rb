# frozen_string_literal: true

module Sw
  class Load
    # One run of #call. Load is a frozen Data, as a command must be, so a run's state lives here. It decides whether to
    # download and in what order the cache changes; the Cache and Mapper it directs decide nothing. It remembers what a
    # download mapped to, so the cache it fills isn't mapped again.
    class Run
      # The root and every collection, which together make a complete cache.
      BODIES = [:root, *Mapper::COLLECTIONS.keys].freeze

      def initialize(url, out, token, reload:)
        @url = url
        @reload = reload
        @out = out
        @token = token
      end

      def call
        reload if @reload || !cache.complete?(*BODIES)
        finished
      end

      # The cache changes only if the download maps, so a bad response never replaces a good cache.
      private def reload
        bodies = download
        @finished = map(bodies)
        cache.write(bodies)
      end

      private def finished = @finished ||= map(cache.read(*BODIES))

      private def download
        root = fetch_root.body
        { root:, **fetch_collections(parse(@url) { mapper.links(root) }) }
      end

      private def map(bodies)
        links = parse(@url) { mapper.links(bodies.fetch(:root)) }
        parsed = Mapper::COLLECTIONS.keys.to_h { |name| [name, parse(links.fetch(name)) { mapper.parse(bodies.fetch(name)) }] }
        Finished.new(**mapper.records(**parsed))
      end

      private def fetch_root
        root = @out.source(Command.http(:get, @url, :root), @token)
        refuse(root, @url) unless root.success?
        root
      end

      private def fetch_collections(links)
        fetches = links.map { |name, link| Command.http(:get, link, name) }
        responses = @out.source(Command.all(:collections, fetches), @token).results
        refused = responses.find { |response| !response.success? }
        refuse(refused, links.fetch(refused.envelope)) if refused
        responses.to_h { |response| [response.envelope, response.body] }
      end

      # Ends the run with a Failed, from anywhere inside it.
      private def refuse(response, from)
        throw :failed, Failed.new(reason: response.error || "HTTP #{response.status} from #{from}")
      end

      private def parse(from)
        yield
      rescue JSON::ParserError
        throw :failed, Failed.new(reason: "Couldn't read the response from #{from}")
      end

      private def mapper = @mapper ||= Mapper.new

      private def cache = @cache ||= Cache.new
    end
  end
end
