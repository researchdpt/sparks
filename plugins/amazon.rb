module URL
    class Amazon
        include Cinch::Plugin

        def self.regex
            %r{(http(?:s)?:\/\/(?:www\.)?amazon(?:[^ ?&/]+)\/[^ ?&/]+\/[^ ?&/]+\/([^ ?&/]+))}
        end

        set :help, <<-EOF
[\x0307Help\x03] Amazon - This module supports URL parsing for products from most amazon sites.
        EOF

        match %r{(http(?:s)?:\/\/(?:www\.)?amazon(?:[^ ?&/]+)\/[^ ?&/]+\/[^ ?&/]+\/([^ ?&/]+))}, use_prefix: false, method: :amazon_product

        def amazon_product(m, url, id)
            uri  = URI.parse(url)
            page = Helpers.api_dict.get("title").get(uri)

            title = page.search("span#productTitle").text.strip

            if title.split(" ").count > 5
                title = title.split(" ")[0..4].join(" ") + "..."
            elsif title.length > 25
                title = title[0..24] + "..."
            end

            price = page.search("span#priceblock_ourprice").text.sub("Â", "")

            fixed_url = url.split("/")
            
            if fixed_url[2].include? ".com"
                fixed_url[3] = "product"
            end

            fixed_url = fixed_url[0..6].join("/")

            m.reply "[\x0307Amazon\x03] \"#{title}\" - #{price} - #{fixed_url}"
        end
    end
end