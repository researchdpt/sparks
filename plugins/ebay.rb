module URL
    class EBay
        include Cinch::Plugin

        def self.regex
            %r{(http(?:s)?:\/\/(?:www\.)?ebay[^ ?&/]+\/itm\/[^ ?&/]*\/([^ ?&/]+))}
        end

        set :help, <<-EOF
[\x0307Help\x03] eBay - This module supports URL parsing from most eBay auctions.
        EOF

        match %r{(http(?:s)?:\/\/(?:www\.)?ebay[^ ?&/]+\/itm\/[^ ?&/]*\/([^ ?&/]+))}, use_prefix: false, method: :ebay_product

        def ebay_product(m, url, id)
            uri  = URI.parse(url)
            page = Helpers.api_dict.get("title").get(uri)

            title = page.search("h1#itemTitle").text.gsub("\u00A0", "").gsub("Details about ", "")

            if title.split(" ").count > 5
                title = title.split(" ")[0..4].join(" ") + "..."
            elsif title.length > 25
                title = title[0..24] + "..."
            end

            unless page.search("span#prcIsum").nil?
                bn_price = page.search("span#prcIsum").text.sub("Â", "")
            end

            unless page.search("span#prcIsum_bidPrice").nil?
                bid_price = page.search("span#prcIsum_bidPrice").text.sub("Â", "")
            end

            if bn_price != "" && bid_price != ""
                price = "Bid: #{bid_price} - Buy Now: #{bn_price}"
            elsif bid_price != ""
                price = "Bid: #{bid_price}"
            elsif bn_price != ""
                price = "Buy Now: #{bn_price}"
            end

            fixed_url = url.split("/")
            
            fixed_url[4] = ""

            fixed_url = fixed_url[0..5].join("/")

            m.reply "[\x0304e\x03\x0312B\x03\x0308a\x03\x0309y\x03] \"#{title}\" - #{price} - #{fixed_url}"
        end
    end
end