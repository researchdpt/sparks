module Helpers
    class HistoryLog
        attr_reader :logs

        def initialize
            @@logs = {}
        end

        def add(channel, user, nick, msg)
            (@@logs[channel.name] ||= []) << HistoryEntry.new(user, nick, msg)

            if @@logs[channel.name].count > 30
                @@logs[channel.name] = @@logs[channel.name][-30..-1]
            end
        end

        def get(flag, channel,  user=nil)
            if flag == "channel"
                @@logs[channel]
            elsif flag == "user" and !user.nil?
                @@logs[channel].select { |log| log.user == user }
            elsif flag == "nick" and !user.nil?
                @@logs[channel].select { |log| log.nick == user }
            end
        end
    end

    class HistoryEntry
        attr_reader :user, :nick, :msg, :timestamp

        def initialize(user, nick, msg)
            @user = user
            @nick = nick
            @msg = msg
            @timestamp = Time.now.to_i
        end
    end

    @@log = HistoryLog.new

    def log
        @@log
    end

    module_function :log
end