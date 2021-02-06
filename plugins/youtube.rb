require 'yt'

module URL
    class YouTubeAPI
        include Cinch::Plugin

        def self.required_config
            ["settings:YouTube:key"]
        end

        def self.regex
            Regexp.union(%r{http(?:s)?:\/\/(?:www.)?youtube\.com\/watch\?v=([^ ?&/]+)}, %r{http(?:s)?:\/\/(?:www.)?youtube\.com\/channel\/([^ ?&/]+)}, %r{http(?:s)?:\/\/youtu\.be\/([^ ?&/]+)})
        end

        set :help, <<-EOF
[\x0307Help\x03] YouTube - This module supports URL parsing for videos and channels.
        EOF

        match %r{http(?:s)?:\/\/(?:www.)?youtube\.com\/watch\?v=([^ ?&/]+)}, use_prefix: false, method: :youtube_video
        match %r{http(?:s)?:\/\/(?:www.)?youtube\.com\/channel\/([^ ?&/]+)}, use_prefix: false, method: :youtube_channel
        match %r{http(?:s)?:\/\/youtu\.be\/([^ ?&/]+)}, use_prefix: false, method: :youtube_shortened
        listen_to :connect, method: :setup

        def setup(m)
            unless Helpers.api_dict.get "yt"
                api =  Yt.configure do |c|
                    c.api_key = Helpers.config.get("settings:YouTube:key")
                end
                Helpers.api_dict.add "yt", api
            end
        end

        def youtube_video(m, video_id)
            fetch_video(m, video_id)
        end

        def youtube_shortened(m, video_id)
            fetch_video(m, video_id)
        end

        def youtube_channel(m, channel_id)
            channel = Yt::Channel.new id: channel_id
            m.reply("[\x0304YouTube\x03] #{channel.title} - Videos: #{channel.video_count} - Subscribers: #{channel.subscriber_count}")
        end

        def fetch_video(m, video_id)
            video = Yt::Video.new id: video_id
            m.reply("[\x0304YouTube\x03] \"#{video.title}\" by #{video.channel_title} from #{video.published_at.strftime("%F %R")} - #{video.length} - Views: #{video.view_count} - \x0303⬆#{video.like_count} \x0304⬇#{video.dislike_count}\x03 - Comments: #{video.comment_count}")
        end
    end
end