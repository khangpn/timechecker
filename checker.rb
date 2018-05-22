#!/usr/bin/env ruby

#require 'net/http'
#require 'uri'
#require 'json'
require './database.rb'
require 'selenium-webdriver'
require 'io/console'

class Checker
  STATE_IN = 1
  STATE_OUT = 0
  PRONET_URL = "https://pronet01.myprotime.be/pronetEE.premnat01/forms/login.aspx?Customer=62"

  def initialize(mode="development")
    @mode = mode
    @db = Database.new()
    @driver = initate_driver
  end

  def checkTime(cardId)
    credential = @db.getByCardId(cardId)
    unless (credential.nil?)
      if (credential["state"] == STATE_IN)
        puts "Clocking out..."
        if clock_out(credential)
          @db.setStateOut(cardId)
          puts "Bye bye '#{credential['username']}'!"
        end
      else
        puts "Clocking in..."
        if clock_in(credential)
          @db.setStateIn(cardId)
          puts "Hello '#{credential['username']}'! "
        end
      end
    else
      puts "Your card ID is not registered yet"
    end
  end
  
  def clock_in(credential)
    begin
      input_general_data credential
      click_clock_in
      #log_out
      return true
    rescue => ex
      puts "!!! Problem with webdrive !!! Cannot proceed!"
      puts ex
      return false
    end
  end
  
  def clock_out(credential)
    begin
      input_general_data credential
      click_clock_out
      #log_out
      return true
    rescue => ex
      puts "!!! Problem with webdrive !!! Cannot proceed!"
      puts ex
      return false
    end
  end

  def toggle_clock(credential)
    clock_in credential
  end

  private
    def click_clock_in
      btn = @driver.find_element(:id, 'LinkPunchIn')
      btn.click
    end

    def click_clock_out
      btn = @driver.find_element(:id, 'LinkPunchOut')
      btn.click
    end

    def log_in
      btn = @driver.find_element(:id, 'ButtonLogin')
      btn.click
    end

    def log_out
      wait = Selenium::WebDriver::Wait.new(:timeout => 10)
      wait.until {
        @driver.switch_to.frame @driver.find_element(:name, 'main')
        btn = @driver.find_element(:id, "LogoutButton")
        btn.click
        @driver.switch_to.default_content
      }
    end

    def input_general_data credential
      @driver.navigate.to PRONET_URL

      username_input = @driver.find_element(:id, 'Username')
      username_input.send_keys credential['username']
      password_input = @driver.find_element(:id, 'Password')
      password_input.send_keys credential['password']
    end

    def initate_driver
      default_profile = Selenium::WebDriver::Firefox::Profile.from_name "default"
      default_profile.secure_ssl = true
      default_profile.native_events = true
      
      options = Selenium::WebDriver::Firefox::Options.new(profile: default_profile)
      options.headless! if (@mode == "production")
      driver = Selenium::WebDriver.for :firefox, options: options
      driver.manage.timeouts.implicit_wait = 5
      driver
    end
end

puts "="*40
puts "|| Starting the time checking system ||"
puts "="*40

mode = (ARGV[0].nil? || ARGV[0].empty? || ARGV[0].match(/^(development|production)$/).nil?) ? "development" : ARGV[0]
checker = Checker.new(mode)

while (true) do
  puts ("Please put your card on the reader: ")
  #print ("Please put your card on the reader: ")
  #cardId = gets.strip
  cardId = STDIN.noecho(&:gets).strip
  checker.checkTime(cardId)
  puts ">"*40
end
