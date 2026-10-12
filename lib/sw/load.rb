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
      root = out.source(Command.http(:get, url, :root), token)
      return out.put(Failed.new(reason: root.error)) if root.error?

      bodies = crawl(out, token, root)
      out.put(Finished.new(
        characters: mapper.characters(bodies.fetch(:people)),
        vehicles: mapper.vehicles(bodies.fetch(:vehicles))
      ))
    end

    private def crawl(out, token, root)
      fetches = mapper.links(root.body).map { |name, link| Command.http(:get, link, name) }
      collections = out.source(Command.all(:collections, fetches), token)
      collections.results.to_h { |response| [response.envelope, response.body] }
    end

    private def mapper = Mapper.new
  end
end
