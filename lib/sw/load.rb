# frozen_string_literal: true

module Sw
  # The command that delivers the whole dataset in one message, from the cache or the API. Each Run does the work; this
  # is the one place an exception becomes a Failed.
  class Load < Data.define(:url, :reload)
    include Rooibos::Command::Custom

    Command = Rooibos::Command

    # The message Load sends when the whole dataset has arrived. Data from a stale cache is still whole, but needs reloading.
    class Finished < Data.define(:characters, :vehicles, :starships, :films, :planets, :species, :stale)
      include Rooibos::Message::Predicates

      def initialize(stale: false, **) = super
    end

    # The message Load sends when the download fails.
    class Failed < Data.define(:reason)
      include Rooibos::Message::Predicates

      # A message must be Ractor-shareable, and a reason built by interpolation isn't frozen.
      def initialize(reason:) = super(reason: reason.freeze)
    end

    def initialize(url: ENV.fetch("SW_API_URL", API_URL), reload: false) = super

    def call(out, token)
      out.put(catch(:failed) { Run.new(url, out, token, reload:).call })
    rescue => e
      out.put(Failed.new(reason: e.message))
    end
  end
end
