class Help
    include Cinch::Plugin
    
    match "help"
    listen_to :connect, method: :setup
    
        set :help, <<-EOF
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}help - Lists plugins that support help.        
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}help <plugin> - Gets help for <plugin>.
        EOF

    def setup(m)
        @@plugins = bot.config.plugins.plugins.select { 
            |plugin| plugin.help 
        }
        
        @@output =  @@plugins.map{ |plugin| 
            format_plugin_name(plugin)
        }
    end
    
    def execute(m)
        m.reply("[\x0307Help\x03] Available plugins for help: #{@@output.join(", ")}.")
    end
    
    def format_plugin_name(plugin)
        plugin.to_s.split("::").last.downcase
    end
end
