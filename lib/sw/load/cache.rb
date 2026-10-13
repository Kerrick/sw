# frozen_string_literal: true

require "etcetera"
require "fileutils"

module Sw
  class Load
    # A Gateway to the raw responses on disk, never the domain objects, so a fix to the Mapper applies to a cache already
    # there. It answers questions about the cache but decides nothing: when to reload it is Run's call.
    class Cache < Data.define(:directory)
      # Names the platform's user cache directory for this app: ~/Library/Caches/com.kerricklong.sw on macOS.
      APP = Etcetera::AppStrategy::AppStrategyArgs.new(top_level_domain: "com", author: "kerricklong", app_name: "sw")

      def initialize(directory: Etcetera::AppStrategy.choose_native_strategy(APP).cache_dir) = super

      def complete?(*names) = names.all? { |name| file(name).file? }

      # The oldest file's time, so a write that stopped partway counts as old.
      def modified(*names) = names.map { |name| file(name).mtime }.min

      def read(*names) = names.to_h { |name| [name, file(name).binread] }

      def write(bodies)
        FileUtils.mkdir_p(directory)
        bodies.each { |name, body| File.binwrite(file(name), body) }
      end

      private def file(name) = directory.join("#{name}.json")
    end
  end
end
