class LastFM
    include Cinch::Plugin

    def self.required_config
        ["settings:LastFM:key"]
    end

    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}lfm config user <lastfm username> - Saves an association between you and your lastfm username in the bot's DB.
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}lfm lp <lastfm username> - Gets the last played or currently playing track for <lastfm username>.
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}lfm lp - If an association is stored for you, it will fetch the last played or currently playing track for it.
    EOF

    match /lfm config user (\S*)/, method: :lastfm_config
    match /lfm lp ?(\S*)?/, method: :lastfm_tracks                
    listen_to :connect, method: :connect_handler
    
    def connect_handler(m)
        bot.db.create_table? :lfm do
            primary_key :id
            String :irc_user, unique: true, null: false
            String :lfm_user, null: false
        end

        @@lfm_db = bot.db[:lfm]
    end

    def lastfm_config(m, user_name)
        if @@lfm_db.where(:irc_user => m.user.user).count == 0
            @@lfm_db.insert(:irc_user => m.user.user, :lfm_user => user_name)
            m.reply "[\x0304LastFM\x03] Associated #{m.user.nick} with #{user_name}."
        else
            @@lfm_db.where(:irc_user => m.user.user).update(:lfm_user => user_name)
            m.reply "[\x0304LastFM\x03] Updated association to #{m.user.nick} with #{user_name}."
        end
    end

    def get_user(use_name)
        unless @@lfm_db.where(:irc_user => m.user.user).count == 0
            @@lfm_db.where(:irc_user => user_name).get(:lfm_user)
        else
            false
        end
    end

    def lastfm_tracks(m, user_name)
        if user_name == ""
            user_name = @@lfm_db.where(:irc_user => m.user.user).get(:lfm_user)
        end

        uri = URI("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&period=overall&limit=3&user=#{user_name}&api_key=#{Helpers.config.get("settings:LastFM:key")}&format=json")
        page = Net::HTTP.get(uri)
        lfm = JSON.parse(page)
        
        last_track = lfm['recenttracks']['track'][0]
        user = lfm['recenttracks']['@attr']['user']
        artist = last_track['artist']['#text']
        track = last_track['name']
        album = last_track['album']['#text']

        if last_track.dig("@attr", "nowplaying")
            playing = true
        else
            time = Time.at(last_track["date"]["uts"].to_i).strftime("%F %T")
            playing = false          
        end
        
        if playing
            m.reply("[\x0304LastFM\x03] \x02#{user}\x02 is currently listening to \"#{track}\" by #{artist}, from the album #{album}.")
        else
            m.reply("[\x0304LastFM\x03] \x02#{user}\x02 last listened to \"#{track}\" by #{artist}, from the album \"#{album}\" at #{time}.")
        end
    end
end