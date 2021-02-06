class Wolfram
    include Cinch::Plugin

    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}wolfram/wa <query> - Searches WolframAlpha for your query.
        EOF
    
    match /(?:wa|wolfram) (.*)/, method: :wolfram

    def wolfram(m, query)
        m.reply "[Wolfram] Querying. This may take a while..."

        uri = URI("http://api.wolframalpha.com/v2/query?appid=#{Helpers.config.get("settings:Wolfram:key")}&input=#{query}")
        page = Net::HTTP.get(uri)
        list = Nokogiri::XML.parse(page)

        if list && list.xpath('queryresult').first.attributes["success"]
            result = list.xpath("//plaintext")[1].text
            result.lines.each { |line| 
                m.reply "[Wolfram] #{line}"
            }
        end
    end
end