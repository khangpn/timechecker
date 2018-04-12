#!/home/kng/.rvm/rubies/ruby-2.4.1/bin/ruby

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
    puts "Clocking IN"
    #serviceUrl =  URI.parse("https://pronet01.myprotime.be/ProNetEE.premnat01/Forms/login.aspx?AutoAuthenticate=0&&Customer=62")
    #header = {
    #  'Content-Type': 'text/html; charset=utf-8'
    #}
    #http = Net::HTTP.new(serviceUrl.host, serviceUrl.port)
    #http.set_debug_output($stdout)
    #request = Net::HTTP::Post.new(serviceUrl.request_uri, header)
    #serviceConfig = JSON.parse(File.read('service.config.json'))
    #request.body = serviceConfig.merge({
    #  '__EVENTTARGET': 'LinkPunchIn',
    #  'Username': credential["username"],
    #  'Password': credential["password"]
    #}).to_json

    #response = http.request(request)
    #puts response.inspect

    driver = Selenium::WebDriver.for :chrome
    driver.navigate.to "http://google.com"

    element = driver.find_element(:name, 'q')
    element.send_keys "Selenium Tutorials"
    element.submit

    driver.quit
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
