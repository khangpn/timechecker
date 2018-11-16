#!/usr/bin/env ruby

require 'io/console'
require './database.rb'

class Register
  def initialize()
    @db = Database.new()
  end

  def add(cardId, userName, password)
    credential = @db.getByCardId(cardId)
    if (credential.nil?)
      @db.insert(cardId, userName, password)
      puts "- Register new card successfully"
    else
      puts "- The card already exists"
      puts "- Updating information"
    end
    puts ""
  end
end

puts "="*66
puts "|| Starting the registering service of the time checking system ||"
puts "="*66

register = Register.new()

def print_welcome
  puts "="*40
  puts "||                                     ||"
  puts "||  WELCOME TO THE REGISTERING SYSTEM  ||"
  puts "||                                     ||"
  puts "="*40
end

while (true) do
  system "clear" or system "cls"
  print_welcome
  print ("Please put your card on the reader: ")
  cardId = gets.strip
  print ("Please input your user name: ")
  userName = gets.strip
  print "Please input your password: "
  password = STDIN.noecho(&:gets).strip
  puts "\n>"*40
  
  register.add(cardId, userName, password)

  puts "### Exiting ###"
  sleep 3
end
