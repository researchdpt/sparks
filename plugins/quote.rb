class Quotes
    include Cinch::Plugin
    
    listen_to :connect, method: :connect_handler
    listen_to :join, method: :join_handler
    match /quote add (\w+) (.*)/, method: :add_quote
    match /quote get (\w+)/, method: :get_user_rand_quote
    
    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}quote add <nick> <message> - Adds the message to <nick>'s quotes.
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}quote get <nick> - Gets a random quote from <nick>.
    EOF

    def connect_handler(m)
        bot.db.create_table? :quotes do
            primary_key :id
            String :user_name
            String :nick_name
            String :quote
            Integer :created_at
        end

        @@quotes = bot.db[:quotes]
    end

    def join_handler(m)
        if @@quotes.where(:user_name => m.user.user).count > 0
            rand_id = rand(1..@@quotes.where(:user_name => m.user.user).count)
            puts rand_id

            user_quote = @@quotes.where(:id => rand_id)
            m.reply "[Quotes] #{Time.at(user_quote.get(:created_at)).strftime("%F %T")} <#{user_quote.get(:nick_name)}> #{user_quote.get(:quote)}"
        end
    end

    def add_quote(m, name, quote)
        correctee_history = Helpers.log.get("nick", m.channel.name, name)
        if correctee_history && correctee_history.count > 0
            correctee_history.reverse_each { |line|
                if line.msg == quote
                    @@quotes.insert(:user_name => line.user, :nick_name => line.nick, :quote => line.msg, :created_at => line.timestamp)
                end
                m.reply "[Quotes] Added quote \"#{quote}\" for #{name}."
                break
            }
        end
    end

    def get_user_rand_quote(m, name)
        if @@quotes.where(:nick_name => name).count > 0
            puts @@quotes.where(:nick_name => name).count
            rand_id = rand(1..@@quotes.where(:nick_name => name).count)
            puts rand_id

            user_quote = @@quotes.where(:id => rand_id)
            m.reply "[Quotes] #{Time.at(user_quote.get(:created_at)).strftime("%F %T")} <#{user_quote.get(:nick_name)}> #{user_quote.get(:quote)}"
        end
    end
end