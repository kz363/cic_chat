#!/usr/bin/env ruby -w
require "socket"
class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @clients = Hash.new
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exist"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "Connection established, Thank you for joining! Happy chatting\n\r"
        print_user_login( nick_name )
        list_current_users( client )
        listen_user_messages( nick_name, client )
      end
    }
  end

  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      puts "#{username.to_s}: #{msg}"
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "#{username.to_s}: #{msg}"
        end
      end
    }
  end

  def list_current_users( client )
    client.puts "Users currently logged in:"
    @connections[:clients].each_key do |name|
      client.puts name
    end
  end

  def print_user_login( name )
    @connections[:clients].each_value do |client|
      client.puts "#{name} has logged in"
    end
  end

end

Server.new( 3333, "localhost" )
