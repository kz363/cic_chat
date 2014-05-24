require "socket"
require 'highline/import'

class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    logout
    @logout.join
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

  def logout
    @logout = Thread.new do
      loop {
        trap("INT") do
          puts "\nDisconnecting."
          @server.puts "quit"
          @server.close
          exit
        end
      }
    end
  end
end
require 'pry'
server = TCPSocket.open( "localhost", 3333 )
# binding.pry
Client.new( server )

