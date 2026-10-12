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
      return report_failure(out, root, url) unless root.success?

      links = links_in(root)
      return out.put(Failed.new(reason: "Couldn't read the response from #{url}".freeze)) unless links

      fetches = links.map { |name, link| Command.http(:get, link, name) }
      responses = out.source(Command.all(:collections, fetches), token).results
      refused = responses.find { |response| !response.success? }
      return report_failure(out, refused, links.fetch(refused.envelope)) if refused

      bodies = responses.to_h { |response| [response.envelope, response.body] }
      out.put(Finished.new(
        characters: mapper.characters(bodies.fetch(:people)),
        vehicles: mapper.vehicles(bodies.fetch(:vehicles))
      ))
    rescue => e
      out.put(Failed.new(reason: e.message.freeze))
    end

    private def links_in(root)
      mapper.links(root.body)
    rescue JSON::ParserError
      nil
    end

    private def report_failure(out, response, from)
      out.put(Failed.new(reason: (response.error || "HTTP #{response.status} from #{from}").freeze))
    end

    private def mapper = Mapper.new
  end
end
