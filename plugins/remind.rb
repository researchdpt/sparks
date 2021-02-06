require 'cinch'
require 'rufus-scheduler'

class Reminder
    include Cinch::Helpers
    
    attr_reader :target, :sender, :created_at, :remind_at, :text
    
    def initialize(bot, target, sender, created_at, remind_at, text)
        @bot = bot
        @target = target.to_s
        @sender = sender
        @created_at = created_at
        @remind_at = remind_at
        @text = text
    end
end

class Reminders
    include Cinch::Plugin
    include Cinch::Helpers
    
    Day_reg = /days?|d/
    Hour_reg = /hours?|hrs?|h/
    Week_reg = /weeks?|wks?|w/
    Year_reg = /years?|yrs?|y/
    Minute_reg = /minutes?|mins?|m/
    Second_reg = /seconds?|secs?|s/
    Time_unit_reg = Regexp.union(Day_reg, Hour_reg, Week_reg, Year_reg, Minute_reg, Second_reg)

    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.config.get("prefix") ? Helpers.config.get("prefix") : "!"}in <time> <text> - Sets a reminder <time> from now. Example: \"!in 5m 4s hello\".
    EOF
    
    match /in ((?:\d+[\s]?\w+\s?)+) (.*)/
    listen_to :connect, method: :load_reminders
    
    def initialize(*args)
        super
        @@scheduler = Rufus::Scheduler.new
    end
    
    def load_reminders(m)
        @@reminders = []
        
        bot.db.create_table? :reminders do
            primary_key :id
            String :target
            String :sender
            Integer :created_at
            Integer :remind_at
            String :text
        end

        @@remindersDB = bot.db[:reminders]
               
        remindersList = @@remindersDB.all
        
        if remindersList != nil
            remindersList.each { |reminder|
                add_reminder(bot, reminder[:target].to_s, reminder[:sender].to_s, reminder[:created_at], reminder[:remind_at], reminder[:text], true)
            }
        end
    end
    
    def execute(m, times, text)
        time_list = parse_time_list(times)

        time_to_add = 0
        time_list.each_slice(2) do |time|
            quantity = is_int? time[0]
            time_unit = parse_time_unit time[1]
            if quantity and time_unit
                time_to_add += quantity * time_unit
            else
                m.reply "[\x0309Reminder\x03] Invalid time format. Reminder not set."
                return
            end
        end

        time_was = Time.now.to_i
        remind_at = time_was + time_to_add
        add_reminder(bot, m.target, m.user.user, time_was, remind_at.to_i, text, false)
        m.reply "[\x0309Reminder\x03] Okay, I'll remind you about that at #{Time.at(remind_at).strftime("%F %T")}"
    end

    def add_reminder(bot, target, sender, created_at, remind_at, text, lock)
        time_to_add = remind_at - Time.now.to_i
        
        if time_to_add <= 0
            debug "Past reminder for #{target} \"#{text}\" triggered."
            @@remindersDB.where(Sequel[:remind_at] <= Time.now.to_i).delete
            Target(target).send("[\x0309Reminder\x03] #{sender}: At #{Time.at(created_at).strftime("%F %T")}, you asked me to remind you about: \"#{text}\". Sorry for being late!")
        else
            reminder = Reminder.new(bot, target, sender, created_at, remind_at, text)
            
            unless lock
                @@remindersDB.insert(:target => target.to_s, :sender => sender.to_s, :created_at => created_at, :remind_at => remind_at, :text => text)
            end
            
            debug "Reminder for #{target} \"#{text}\" created."
            @@reminders << reminder
            @@scheduler.in "#{time_to_add}s" do
                debug "Reminder for #{target} \"#{text}\" triggered."
                
                @@reminders.each { |reminder|
                    if reminder.remind_at <= Time.now.to_i 
                        Target(target).send("[\x0309Reminder\x03] #{reminder.sender}: At #{Time.at(reminder.remind_at).strftime("%F %T")}, you asked me to remind you about: \"#{reminder.text}\"")
                        @@remindersDB.where(Sequel[:remind_at] <= Time.now.to_i).delete
                        @@reminders.delete(reminder)
                    end
                }
            end 
        end
    end

    def is_int?(given_str)
        begin
            return Integer(given_str)
        rescue
            return nil
        end
    end
    
    def parse_time_unit(str_unit)
        if str_unit =~ /^#{Day_reg}/
            return 24*60*60
        elsif str_unit =~ /^#{Hour_reg}/
            return 60*60
        elsif str_unit =~ /^#{Week_reg}/
            return 7*24*60*60
        elsif str_unit =~ /^#{Year_reg}/
            return 365*24*60*60
        elsif str_unit =~ /^#{Minute_reg}/
            return 60
        elsif str_unit =~ /^#{Second_reg}/
            return 1
        end

        return nil
    end
    
    def parse_time_list(times)
        to_return = []
        current_item = ''
        last_type = :whitespace
        times.each_char do |char|
            if char == ' '
                last_type = :whitespace
                unless current_item == '' || current_item == 'and'
                    to_return << current_item
                end
                current_item = ''
            elsif char =~ /[[:alpha:]]/
                if last_type == :digit
                    to_return << current_item
                    current_item = ''
                end
                current_item += char
                last_type = :alpha
            else
                current_item += char
                last_type =:digit
            end
        end

        unless current_item == '' || current_item == 'and'
            to_return << current_item
        end

        return to_return
    end
end
