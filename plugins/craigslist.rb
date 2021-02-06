module URL
    class CraigsList
        include Cinch::Plugin

        def self.regex
            %r{(http(?:s)?:\/\/[^ \.]+\.craigslist(?:[^ \d+]+)(?:\d+).html)}
        end

        set :help, <<-EOF
[\x0307Help\x03] CraigsList - This module supports URL parsing from most craigslist listings.
        EOF

        match %r{(http(?:s)?:\/\/[^ \.]+\.craigslist(?:[^ \d+]+)(?:\d+).html)}, use_prefix: false, method: :craigslist_listing

        def craigslist_listing(m, url)
            uri  = URI.parse(url)
            page = Helpers.api_dict.get("title").get(uri)

            title = page.search("span#titletextonly").text
            subtitle = page.search("h2.postingtitle span.postingtitletext small").text.gsub(/([()])/, "")

            if title.split(" ").count > 5
                title = title.split(" ")[0..4].join(" ") + "..."
            elsif title.length > 25
                title = title[0..24] + "..."
                puts title
            end

            posted = " - Posted at: #{Time.parse(page.search("time.date.timeago").text).strftime("%F %T")}"

            m.reply "[\x0306CraigsList\x03] \"#{title}\" - \"#{subtitle}\"#{posted}"
        end
    end
end