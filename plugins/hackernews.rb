module URL
    class HackerNews
        include Cinch::Plugin

        def self.regex
            Regexp.union(%r{http(?:s):\/\/news.ycombinator\.com/item\?id=([^ ?&/]+)}, %r{http(?:s):\/\/news.ycombinator\.com/user\?id=([^ ?&/]+)})
        end

        set :help, <<-EOF
[\x0307Help\x03] HackerNews - This module supports URL parsing for posts and users.
        EOF

        match %r{http(?:s):\/\/news.ycombinator\.com/item\?id=([^ ?&/]+)}, use_prefix: false, method: :get_post
        match %r{http(?:s):\/\/news.ycombinator\.com/user\?id=([^ ?&/]+)}, use_prefix: false, method: :get_user
        listen_to :connect, method: :setup

        def setup(m)
            unless Helpers.api_dict.get "hn"
                Helpers.api_dict.add "hn", true
            end
        end

        def get_post(m, id)
            uri = URI("https://hacker-news.firebaseio.com/v0/item/#{id}.json")
            page = Net::HTTP.get(uri)
            post = JSON.parse(page)

            unless post["url"].nil?
                url = " - #{post["url"]}"
            end

            m.reply("[\x0307HackerNews\x03] \"#{post["title"]}\" by \"#{post["by"]}\" - Score: #{post["score"]} - At: #{Time.at(post["time"]).strftime("%F %R")}#{url}")
        end

        def get_user(m, id)
            uri = URI("https://hacker-news.firebaseio.com/v0/user/#{id}.json")
            page = Net::HTTP.get(uri)
            user = JSON.parse(page)

            m.reply("[\x0307HackerNews\x03] #{user["id"]} - Karma: #{user["karma"]} - Joined at: #{Time.at(user["created"]).strftime("%F %R")}")
        end
    end
end