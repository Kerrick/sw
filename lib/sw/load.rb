# frozen_string_literal: true

module Sw
  # Crawls the API from its root and delivers what it finds in one message.
  class Load < Data.define(:url)
    include Rooibos::Command::Custom

    Command = Rooibos::Command

    # The message Load sends when the whole dataset has arrived.
    class Finished < Data.define(:characters, :vehicles)
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
      links = parse(url) { mapper.links(fetch_root(out, token).body) }
      bodies = fetch_collections(out, token, links)
      Finished.new(
        characters: parse(links.fetch(:people)) { mapper.characters(bodies.fetch(:people)) },
        vehicles: parse(links.fetch(:vehicles)) { mapper.vehicles(bodies.fetch(:vehicles)) }
      )
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

    private def failure(reason) = Failed.new(reason: reason.freeze)

    private def mapper = Mapper.new
  end
end
