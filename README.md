# Sparks

an irc bot forked by research

```
bundle install
ruby main.rb
```

## config.yaml

```yaml
nick: Sparks
user: sparks
real: Sparks
address: 0.0.0.0
password: Sparks/ZNC:password
port: 6667
ssl: No
oper:
    user: No
    pass: No

channels:
    - "#bottest"

plugins:
    - Reminders
    - History
    - Sed
    - Oper
    - Quotes
    - Feeds
    - URL::Title
    - URL::GitHubAPI
    - URL::TwitterAPI
    - URL::YouTubeAPI
    - URL::Wikipedia
    - URL::Amazon
    - URL::EBay
    - URL::TradeMe
    - URL::CraigsList
    - URL::HackerNews
    - LastFM
    - Wolfram
    - Weather
    - Help
    - Gimmicks::Nep
    - Gimmicks::BlazeIt
    - Gimmicks::TextLoaders

settings:
    Wikipedia:
        lang: en
    OpenWeatherMap:
        type: metric
        key: No
    Twitter:
        key: No
        secret: No
    GitHub:
        key: No
        secret: No
    YouTube:
        key: No
    LastFM:
        key: No
    Wolfram:
        key: No
```

## Plugins

* Reminders
	* Triggered by something like `!in 5 hours 4 minutes test`.
	* Persistent, stored in the SQLite database.

* Sed - Like the UNIX program 'sed'.

* URL Handling
	* YouTube
		* Videos
        * Channels
	* GitHub
		* Repositories
		* Profiles
		* Gists
        * Pulls
        * Issues
	* Twitter
		* Profiles
		* Statuses
	* Fallback

* LastFM Last Play / Now Playing
    * Users can configure it to associate their IRC username to their LFM username and it is persistently kept in the DB.

* Weather
	* Provided by OpenWeatherMap.
