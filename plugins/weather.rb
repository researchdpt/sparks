require 'net/http'
require 'json'

class Weather
    include Cinch::Plugin

    def self.required_config
        ["settings:OpenWeatherMap:key"]
    end

    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}weather <location> - Gets weather information for <location> from OpenWeatherMap.
    EOF
    
    match /weather (.+)/

    listen_to :connect, method: :setup

    def setup(m)
        unless Helpers.api_dict.get "owm"
            Helpers.api_dict.add "owm", Helpers.config.get("settings:OpenWeatherMap:key")
        end
    end

    def weather(location)
        uri = URI("http://api.openweathermap.org/data/2.5/weather?q=#{location}&units=#{Helpers.config.get("settings:OpenWeatherMap:type")}&appid=#{Helpers.api_dict.get "owm"}")
        page = Net::HTTP.get(uri)
        weather = JSON.parse(page)

        if weather != nil and weather["name"] != nil
            if Helpers.config.get("settings:OpenWeatherMap:type") == "metric"
                location = "#{weather["name"]}, #{weather["sys"]["country"]}"
                celsius = "#{weather["main"]["temp"]}°C"
                description = weather["weather"][0]["main"]
                humidity = "#{weather["main"]["humidity"]}%"
                wind_speed = "#{weather["wind"]["speed"]}km/h"
            elsif Helpers.config.get("settings:OpenWeatherMap:type") == "imperial"
                location = "#{weather["name"]}, #{weather["sys"]["country"]}"
                celsius = "#{weather["main"]["temp"]}°F"
                description = weather["weather"][0]["main"]
                humidity = "#{weather["main"]["humidity"]}%"
                wind_speed = "#{weather["wind"]["speed"]}mph"
            end                    

            return "[\x0311Weather\x03] #{location}, #{celsius}, #{description}, #{humidity}, #{wind_speed}"
        end
        return "[\x0311Weather\x03] Error."
    end

    def execute(m, location)
        m.reply(weather(location))
    end
end
