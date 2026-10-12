# frozen_string_literal: true

module Sw
  # Crawls the API from its root and delivers what it finds in one message.
  class Load < Data.define(:url)
    include Rooibos::Command::Custom

    Command = Rooibos::Command

    def call(out, token)
      bodies = crawl(out, token)
      out.put(Loaded.new(
        characters: mapper.characters(bodies.fetch(:people)),
        vehicles: mapper.vehicles(bodies.fetch(:vehicles))
      ))
    end

    private def crawl(out, token)
      root = out.source(Command.http(:get, url, :root), token)
      fetches = mapper.links(root.body).map { |name, link| Command.http(:get, link, name) }
      collections = out.source(Command.all(:collections, fetches), token)
      collections.results.to_h { |response| [response.envelope, response.body] }
    end

    private def mapper = Mapper.new
  end
end
