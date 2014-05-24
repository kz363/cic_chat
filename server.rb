require "socket"
require 'highline/import'

class Server
  def initialize( ip, port )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @clients = Hash.new
    @connections[:clients] = @clients
    trap_shutdown
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
        client.puts "\e[H\e[2JYou've connected to cic_chat! Happy chatting.\n\r"
        print_user_login( nick_name )
        list_current_users( client )
        listen_user_messages( nick_name, client )
      end
    }
  end

  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      disconnect_client( username ) if msg == "quit"
      msg = "(#{Time.now.strftime "%H:%M:%S"})" + HighLine.color(" #{username.to_s}:", :bold) + " #{msg}"
      puts msg
      print_message_to_clients( msg )
    }
  end

  def list_current_users( client )
    client.puts "*" * 50 + "\nUsers currently logged in:"
    @connections[:clients].each_key do |name|
      client.puts name
    end
    client.puts "*" * 50 + "\n"
  end

  def print_user_login( name )
    puts ">>#{name} has logged in"
    @connections[:clients].each_value do |client|
      client.puts ">>#{name} has logged in"
    end
  end

  def disconnect_client( name )
    @connections[:clients][name.to_sym].close
    msg = ">>#{name} has logged out"
    puts msg
    @connections[:clients].delete( name )
    print_message_to_clients( msg )
    Thread.kill self
  end

  def print_message_to_clients( msg )
    @connections[:clients].each_value do |client|
      client.puts msg
    end
  end

  def trap_shutdown
    trap("INT") do
      puts "\nClosing server."
      @server.close
      exit
    end
  end
end

Server.new( "localhost", 3333 )
