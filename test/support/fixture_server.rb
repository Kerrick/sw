# frozen_string_literal: true

require "socket"

# Serves the recorded swapi.info responses from a local port. It rewrites the
# API's absolute URLs to point here, so a client that follows them stays local.
class FixtureServer
  FIXTURES = File.expand_path("../fixtures/swapi.info", __dir__)
  RECORDED_URL = "https://swapi.info/api"

  def initialize
    @server = TCPServer.new("127.0.0.1", 0)
    @refused = []
    @dropped = []
    @thread = Thread.new { serve }
  end

  def url = "http://127.0.0.1:#{@server.addr[1]}/api"

  # Answers 404 for the path while the block runs, as if the API had lost it.
  def refusing(path)
    @refused << path
    yield
  ensure
    @refused.delete(path)
  end

  # Closes the connection without answering the path while the block runs, as a dying network would.
  def dropping(path)
    @dropped << path
    yield
  ensure
    @dropped.delete(path)
  end

  def close
    @server.close
    @thread.join
  end

  private def serve
    loop do
      client = @server.accept
      Thread.new { respond(client) }
    end
  rescue IOError
    nil
  end

  private def respond(client)
    path = client.gets.split[1]
    nil until client.gets.chomp.empty?
    return if @dropped.include?(path)

    file = File.join(FIXTURES, "#{path}.json")
    served = File.file?(file) && !@refused.include?(path)
    client.print(served ? ok(File.read(file).gsub(RECORDED_URL, url)) : not_found)
  ensure
    client.close
  end

  private def ok(body)
    <<~HTTP.gsub("\n", "\r\n") + body
      HTTP/1.1 200 OK
      Content-Type: application/json
      Content-Length: #{body.bytesize}
      Connection: close

    HTTP
  end

  private def not_found
    <<~HTTP.gsub("\n", "\r\n")
      HTTP/1.1 404 Not Found
      Content-Length: 0
      Connection: close

    HTTP
  end
end
