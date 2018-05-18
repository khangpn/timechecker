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
    end
    puts ""
  end
end

puts "="*66
puts "|| Starting the registering service of the time checking system ||"
puts "="*66

register = Register.new()

while (true) do
  print ("Please put your card on the reader: ")
  cardId = gets.strip
  print ("Please input your user name: ")
  userName = gets.strip
  print "Please input your password: "
  password = STDIN.noecho(&:gets).strip
  puts "\n>"*40
  
  register.add(cardId, userName, password)
end
