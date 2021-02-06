=begin
                      _
 ___ _ __   __ _ _ __| | _____
/ __| '_ \ / _` | '__| |/ / __|
\__ \ |_) | (_| | |  |   <\__ \
|___/ .__/ \__,_|_|  |_|\_\___/
    |_|

an irc bot forked by research

=end

require 'cinch'
require 'sequel'
require 'yaml'

puts "\e[31m"
puts "                      _"
puts " ___ _ __   __ _ _ __| | _____"
puts "/ __| '_ \\ / _` | '__| |/ / __|"
puts "\\__ \\ |_) | (_| | |  |   <\\__ \\"
puts "|___/ .__/ \\__,_|_|  |_|\\_\\___/"
puts "    |_|"
puts ""
puts "an irc bot forked by research"
puts "\e[0m"

require_relative 'helpers/config'
require_relative 'helpers/history'
require_relative 'helpers/api_setup'

Dir.glob("plugins/*.rb").each do |f|
    require_relative f
    puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [file loader] Loaded: '#{f}'"
end

module Main    
    @@bot = Cinch::Bot.new do
        configure do |c|         
            do_not_load = {}

            c.server = Helpers.config.config["address"]
            c.port = Helpers.config.config["port"]
            c.ssl.use = Helpers.config.config["ssl"]
            c.nick = Helpers.config.config["nick"]
            c.user = Helpers.config.config["user"]
            c.realname = Helpers.config.config["real"]
            c.oper = Helpers.config.config["oper"]
            if Helpers.config.config["password"]
                c.password = Helpers.config.config["password"]
            end
            c.channels = Helpers.config.config["channels"]
            c.messages_per_second = 100000
            
            Helpers.config.config["plugins"].each { |plugin|
                plugin_obj = Kernel.const_get(plugin)

                if defined?(plugin_obj.required_config)
                    plugin_obj.required_config.each do |item|
                        if item.include? ":"
                            items = item.split(":")
                            if Helpers.config.config.dig(*items).nil? || Helpers.config.config.dig(*items) == false
                                (do_not_load[plugin_obj.name] ||= []) << item
                            end
                        else
                            if Helpers.config.config[item] == false
                                (do_not_load[plugin_obj.name] ||= []) << item
                            end
                        end
                    end
                end

                if do_not_load.keys.include? plugin_obj.name
                    puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [plugin loader] Plugin \"#{plugin}\" not loaded due to missing config keys: #{do_not_load[plugin_obj.name].join(", ")}."
                else
                    c.plugins.plugins << plugin_obj
                    puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [plugin loader] Loaded Plugin: #{plugin}"
                end
            }
        end
    end

    @@db = Sequel.sqlite "sparks.db"
    
    def @@bot.db
        @@db
    end
    
    @@bot.start
end

