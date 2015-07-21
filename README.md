# slackleford
slackleford is a modified version of my other bot [MUMfoRd](https://github.com/HuggableSquare/MUIMfoRd)  
but, this bot's job is to bridge mumble chat into slack  
it also will pm you a list of people in the mumble server when it gets the message "users"

how do use
---------
your first job is:

    bundle install

then, your second job is to create a realtime messaging api bot on your slack team and get the api key  
once that's done plug it into the script appropriately  
other than that just make sure you have a "#mumble" channel on your slack team for the bot to message into  
and then, run the bot using this syntax:

    ruby slackleford.rb mumbleserver_host mumbleserver_port mumbleserver_username mumbleserver_userpassword mumbleserver_targetchannel

I would recommend using tmux/screen to run the bot like a daemon

dependencies
---------
- [ruby](https://www.ruby-lang.org/en/)
- [mumble-ruby](https://github.com/mattvperry/mumble-ruby)
- [slack-api](https://github.com/aki017/slack-ruby-gem)  

TODO
-----
- make a better readme
- fix image base64 issue
