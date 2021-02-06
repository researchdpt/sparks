require 'twitter'

module URL
    class TwitterAPI
        include Cinch::Plugin

        def self.required_config
            ["settings:Twitter:key", "settings:Twitter:secret"]
        end

        def self.regex
            %r{http(?:s)?:\/\/(?:www.)?twitter.com\/([^ ?/]+)(?:\/status\/(\d+))?}
        end

        set :help, <<-EOF
[\x0307Help\x03] Twitter - This module supports URL parsing for statuses and users. It also includes basic commands to do the same.
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}twitter profile <username> - Returns <username>'s profile. Can take usernames prefixed with a @.
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}twitter lt <username> - Returns <username>'s last tweet/retweet. Can take usernames prefixed with a @.
        EOF

        match self.regex, use_prefix: false, method: :twitter_url
        match /twitter (profile|lt) @??(\w{1,15})/, method: :twitter
        listen_to :connect, method: :setup

        def setup(m)
            unless Helpers.api_dict.get "twitter"
                api = Twitter::REST::Client.new do |c|
                    c.consumer_key = Helpers.config.get("settings:Twitter:key")
                    c.consumer_secret = Helpers.config.get("settings:Twitter:secret")
                end
                Helpers.api_dict.add "twitter", api
            end
        end

        def twitter_url(m, user_name, status_id)
            if status_id != nil
                status = Helpers.api_dict.get("twitter").status(status_id)

                text = status.text.gsub("\n", " ")

                m.reply("[\x0311Twitter\x03] \"#{text}\" by #{status.user.name} (@#{status.user.screen_name}) from #{status.created_at.strftime("%F %R")} - RTs: #{status.retweet_count} - Favourites: #{status.favorite_count}")
            elsif user_name != nil
                user = Helpers.api_dict.get("twitter").user(user_name.downcase)

                if user.location.length > 0
                    location = " - Location: #{user.location}"
                else
                    location = ""
                end
                if user.description.length > 0
                    description = " - \"#{user.description.gsub(/\R+/, ' ')}\""
                else
                    description = ""
                end
                m.reply("[\x0311Twitter\x03] #{user.name} (@#{user.screen_name})#{location}#{description} - Following: #{user.friends_count} - Followers: #{user.followers_count}")
            end
        end

        def twitter(m, type, query)
            if type == "profile"
                user = Helpers.api_dict.get("twitter").user(query.downcase)

                if user != nil
                    if user.location.length > 0
                        location = " - Location: #{user.location}"
                    else
                        location = ""
                    end
                    if user.description.length > 0
                        description = " - \"#{user.description.gsub(/\R+/, ' ')}\""
                    else
                        description = ""
                    end
                    m.reply("[\x0311Twitter\x03] #{user.name} (@#{user.screen_name})#{location}#{description} - Following: #{user.friends_count} - Followers: #{user.followers_count} - https://twitter.com/#{query}")
                end
            elsif type == "lt"
                status = Helpers.api_dict.get("twitter").user_timeline(query.downcase, count: 1).first

                text = status.text.gsub("\n", " ")

                m.reply("[\x0311Twitter\x03] \"#{text}\" by #{status.user.name} (@#{status.user.screen_name}) from #{status.created_at.strftime("%F %R")} - RTs: #{status.retweet_count} - Favourites: #{status.favorite_count}")
            end
        end
    end
end