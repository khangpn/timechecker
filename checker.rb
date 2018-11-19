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
      count = @db.countLogs(cardId)[0]
      # In fact, pronet handle clock in and out similarly, they count the number or records to
      #distingush in/out action
      # TODO: remove in/out action and handle clocking generally
      out = (count%2 == 0) 
      puts "Saving your time record..."
      if out # We assume that the first time is clocking out
        if clock_out(credential)
          @db.insertLog(cardId)
          puts "Bye bye '#{credential['username']}'!"
          # Log out of pronet
          begin
            log_out
            return true
          rescue => ex
            reset_driver
          end
        end
      else
        if clock_in(credential)
          @db.insertLog(cardId)
          puts "Hello '#{credential['username']}'! "
          # Log out of pronet
          begin
            log_out
            return true
          rescue => ex
            reset_driver
          end
        end
      end
    else
      puts "Your card ID is not registered yet"
      if wanna_register?
        register_card
      end
    end
  end

  def register_card()
    print ("Please put your card on the reader: ")
    cardId = gets.strip
    print ("Please input your user name: ")
    userName = gets.strip
    print "Please input your password: "
    password = STDIN.noecho(&:gets).strip
    puts "\n>"*40
    credential = @db.getByCardId(cardId)
    if (credential.nil?)
      @db.insert(cardId, userName, password)
      puts "- Register new card successfully"
    else
      puts "- The card already exists"
      puts "- Updating information"
    end
  end

  def wanna_register?
    print ("Do you want to register your card?(Y/N) ")
    answer = gets.strip.upcase
    answer == "Y"
  end
  
  def clock_in(credential)
    begin
      input_general_data credential
      click_clock_in
      #log_in
      return true
    rescue => ex
      puts "!!! Problem with webdrive !!! Cannot proceed!"
      puts ex
      reset_driver
      return false
    end
  end
  
  def clock_out(credential)
    begin
      input_general_data credential
      click_clock_out
      #log_in
      return true
    rescue => ex
      puts "!!! Problem with webdrive !!! Cannot proceed!"
      puts "!!! Please try again !!!"
      puts ex
      reset_driver
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
        true #return true to skip the wait
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

    def reset_driver
      @driver.quit  
      @driver = initate_driver
    end
end

system "clear" or system "cls"
puts "="*40
puts "|| Starting the time checking system ||"
puts "="*40

mode = (ARGV[0].nil? || ARGV[0].empty? || ARGV[0].match(/^(development|production)$/).nil?) ? "development" : ARGV[0]
checker = Checker.new(mode)

def print_welcome
  puts "="*40
  puts "||                                     ||"
  puts "|| WELCOME TO THE TIME CHECKING SYSTEM ||"
  puts "||                                     ||"
  puts "="*40
end

while (true) do
  system "clear" or system "cls"
  print_welcome
  puts ("Please put your card on the reader")
  cardId = STDIN.noecho(&:gets).strip
  checker.checkTime(cardId)
  puts "### Exiting ###"
  sleep 3
end
