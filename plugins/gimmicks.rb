module Gimmicks
    class Nep
        include Cinch::Plugin

        match "nep", method: :nep_internally

        def nep_internally(m)
            m.reply "\x0306#{m.user.nick} is nepping internally! >~<  https://cdn.d2k5.com/data/uploads/kiisuke/DrVcBojp8tiywH62PRSu.jpg\x01"
        end
    end
    class BlazeIt
        include Cinch::Plugin

        match /420 ?(.*)?/, method: :blaze_it

        def blaze_it(m, msg)
            if msg != ""
                m.reply "\x0303#{m.user.nick} has some #{msg} and they're blazing it, faggots!\x01"
            else
                m.reply "\x0303#{m.user.nick} is blazing it, faggots!\x01"
            end
        end
    end
    class TextLoaders
        include Cinch::Plugin

        def get_line(type)
            File.readlines("data/#{type}.txt").sample.strip
        end

        match "jerk", method: :jerk
        def jerk(m)
            m.reply "[Jerk] \"#{get_line("jerk")}\""
        end

        match "fart", method: :fart
        def fart(m)
            m.reply "[Fart] \"#{get_line("robofart")}\""
        end

        match "sealab", method: :sealab
        def sealab
            m.reply "[Sealab] \"#{get_line("sealab")}\""
        end
    end
end