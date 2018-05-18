#!/usr/bin/env ruby

#require 'net/http'
#require 'uri'
#require 'json'
require './database.rb'
require 'selenium-webdriver'

class Checker
  def initialize()
    @db = Database.new()
  end

  def checkTime(cardId)
    puts "CardID: #{cardId}"
    credential = @db.getByCardId(cardId)
    puts credential.inspect
    unless (credential.nil?)
      if (credential["state"] == 1)
        clockOut(credential)
      else
        clockIn(credential)
      end
      @db.toggleState(cardId)
    else
      puts "Your card ID is not registered yet"
    end
  end
  
  def clockIn(credential)
    driver = Selenium::WebDriver.for :firefox
    driver.navigate.to "https://pronet01.myprotime.be/pronetEE.premnat01/forms/login.aspx?Customer=62"

    element = driver.find_element(:id, 'Username')
    element.send_keys credential.username
    #element.submit

    puts driver.title

    driver.quit

    puts "Clocking IN"
  end
  
  def clockOut(credential)
    puts "Clocking OUT"
  end
end

puts "="*40
puts "|| Starting the time checking system ||"
puts "="*40

checker = Checker.new()

while (true) do
  print ("Please put your card on the reader: ")
  cardId = gets.strip
  checker.checkTime(cardId)
end
