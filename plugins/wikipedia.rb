module URL
    class Wikipedia
        include Cinch::Plugin

        def self.regex
            %r{http(?:s)?:\/\/(\w+)\.wikipedia\.org\/wiki\/([^ ?&/]+)}
        end

        match %r{http(?:s)?:\/\/(\w+)\.wikipedia\.org\/wiki\/([^ ?&/]+)}, use_prefix: false, method: :say_snippet
        match %r{(?:w|wiki) (.*)}, method: :say_search
        
        set :help, <<-EOF
[\x0307Help\x03] Wikipedia - This module can parse URLs for Wikipedia articles and returns an excerpt of them.
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}wiki|w <query> - This searches Wikipedia for your query and returns an excerpt of the article.
        EOF

        def get_snippet(lang, query)
            uri = URI("https://#{lang}.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&exchars=300&redirects&titles=#{query}")
            page = Net::HTTP.get(uri)
            data = JSON.parse(page)
            

            extract = data.dig("query", "pages")
            unless extract.nil?
                return [extract[extract.keys[0]]["title"], extract[extract.keys[0]]["extract"]]
            else
                return false
            end
        end
        
        def get_search(lang, query, num)
            uri = URI("https://#{lang}.wikipedia.org/w/api.php?format=json&action=query&list=search&srlimit=#{num}&srprop=timestamp&srwhat=text&srsearch=#{query}")
            page = Net::HTTP.get(uri)
            data = JSON.parse(page)

            if data["query"]
                query = data["query"]["search"]
                titles = query.map { |entity| entity["title"] }
                return titles
            else
                return false
            end
        end

        def say_snippet(m, lang, query)
            snippet = get_snippet(lang, query)
            if snippet != false
                m.reply "[Wikipedia] Snippet from \"#{snippet[0]}\": #{snippet[1]}"
            end
        end

        def say_search(m, query)
            result = get_search(Helpers.config.get("settings:Wikipedia:lang"), query, 1)
            if result != false
                snippet = get_snippet(Helpers.config.get("settings:Wikipedia:lang"), query)
                if snippet != false
                    m.reply "[Wikipedia] Snippet from \"#{snippet[0]}\": #{snippet[1]}"
                end
            end
        end
    end
end