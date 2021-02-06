class Oper
    include Cinch::Plugin
    
    listen_to :oper, method: :test

    def test(m)
        puts "This is a test to show that the bot opers and can recognise the IRCd. IRCd:#{m.bot.irc.network.ircd}. Bot is Oper: #{m.bot.is_oper}."
    end
end