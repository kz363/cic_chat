# require 'socket'

# hostname = "10.0.0.45"
# port = 2000

# s = TCPSocket.open(hostname, port)

# while line = s.gets
#   puts line.chop
# end
# s.close

#!/usr/bin/env ruby -w
require "socket"
class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        puts "#{msg}"
      }
    end
  end

  def send
    puts "Enter the username:"
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        @server.puts( msg )
      }
    end
  end
end

server = TCPSocket.open( "10.0.0.45", 3000 )
Client.new( server )
