module URL
    class TradeMe
        include Cinch::Plugin

        def self.regex
            %r{(http(?:s)?:\/\/(?:www.)?trademe.co.nz\/(?:.*))}
        end

        set :help, <<-EOF
[\x0307Help\x03] TradeMe - This module supports URL parsing from most TradeMe auctions.
        EOF

        match %r{(http(?:s)?:\/\/(?:www.)?trademe.co.nz\/(?:.*))}, use_prefix: false, method: :trademe_product

        def trademe_product(m, url)
            uri  = URI.parse(url)
            page = Helpers.api_dict.get("title").get(uri)

            if page.search("div#ListingTitleBox_TitleText").text.length > 0
                title = page.search("div#ListingTitleBox_TitleText").text 

                if title.split(" ").count > 5
                    title = title.split(" ")[0..4].join(" ") + "..."
                elsif title.length > 25
                    title = title[0..24] + "..."
                    puts title
                end
                
                unless page.search("div#BuyNow_BuyNow").nil?
                    bn_price = "NZ" + page.search("div#BuyNow_BuyNow").text
                end
    
                unless page.search("div#Bidding_CurrentBidValue").nil?
                    bid_price = "NZ" + page.search("div#Bidding_CurrentBidValue").text
                end
    
                if bn_price != "" && bid_price != ""
                    price = "Bid: #{bid_price} - Buy Now: #{bn_price}"
                elsif bid_price != ""
                    price = "Bid: #{bid_price}"
                elsif bn_price != ""
                    price = "Buy Now: #{bn_price}"
                end
    
                unless page.search("span#ClosingTime_TimeLeft").nil?
                    closing_time = " - #{page.search("span#ClosingTime_TimeLeft").text.gsub(/([()])/, "")} left"
                end
    
                m.reply "[\x0312Trade\x03\x0308Me\x03] \"#{title}\" - #{price}#{closing_time}"
            end
        end
    end
end