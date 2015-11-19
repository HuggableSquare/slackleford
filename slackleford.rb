#!/usr/bin/env ruby

# Syntax
# ruby slackleford.rb mumbleserver_host mumbleserver_port mumbleserver_username mumbleserver_userpassword mumbleserver_targetchannel

require 'rubygems'
require 'bundler/setup'

require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'
require 'mumble-ruby'
require 'slack'

class MumbleSlack
  IMGUR_ENABLE = 0 # IMPORTANT (0 = NO, 1 = YES)
  API_URI = URI.parse('https://api.imgur.com')
  API_PUBLIC_KEY = 'Client-ID put client-id here' # IMPORANT

  ENDPOINTS = {:image => '/3/image'}

  def imgur_web_client
    http = Net::HTTP.new(API_URI.host, API_URI.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
  end

  def initialize
    @sv_art
    @sv_alb
    @sv_tit

    @mumbleserver_host = ARGV[0].to_s
    @mumbleserver_port = ARGV[1].to_s
    @mumbleserver_username = ARGV[2].to_s
    @mumbleserver_userpassword = ARGV[3].to_s
    @mumbleserver_targetchannel = ARGV[4].to_s

    @cli = Mumble::Client.new(@mumbleserver_host, @mumbleserver_port) do |conf|
      conf.username = @mumbleserver_username
      conf.password = @mumbleserver_userpassword
    end

    Slack.configure do |config|
      config.token = "put api key here" # IMPORTANT
    end
    @client = Slack.realtime
	
    @cli.on_text_message do |msg|
      message = msg.message
      message.gsub!(%r~<br\s*\/?>~, "\n")
      message.gsub!(/&quot;/, '"')
      if @cli.users.has_key?(msg.actor)
        case message
        when /<a href="(.*)">/i
          nolinkmsg = message.match(/<a href="(.*)">/i)
          Slack.chat_postMessage username: "#{@cli.users[msg.actor].name}", channel: "\#mumble", text: "#{nolinkmsg[1]}"
        when /base64,(.*)"\/>/i
          if IMGUR_ENABLE == 1
            img = message.match(/base64,(.*)"\/>/i)[1]
            img.gsub!("%2F", '/')
            img.gsub!("%2B", '+')

            params = {:image => "#{img}"}

            request = Net::HTTP::Post.new(API_URI.request_uri + ENDPOINTS[:image])
            request.set_form_data(params)
            request.add_field('Authorization', API_PUBLIC_KEY)

            response = imgur_web_client.request(request)
            Slack.chat_postMessage username: "#{@cli.users[msg.actor].name}", channel: "\#mumble", text: JSON.parse(response.body)['data']['link']
          elsif IMGUR_ENABLE == 0
            Slack.chat_postMessage username: "#{@cli.users[msg.actor].name}", channel: "\#mumble", text: "Embedded image cannot be displayed."
          end
        else
          Slack.chat_postMessage username: "#{@cli.users[msg.actor].name}", channel: "\#mumble", text: "#{message}"
        end
      end
    end
    @client.on :message do |data|
      case data['text']
      when /^users/i
        usermessage = ""
        channels = {}
        @cli.users.each do |user|
          if user[1].channel_id.nil?
            userchannel = 0
          elsif
            userchannel = user[1].channel_id
          end
          channels["#{@cli.channels[userchannel].name}"] = Array.new unless channels.has_key?("#{@cli.channels[userchannel].name}")
          channels["#{@cli.channels[userchannel].name}"].push "#{user[1].name}"
        end
        channels.each do |channeldata|
          channeldata[1].sort!
          usermessage << "#{channeldata[0]}\n"
          usermessage << "\t#{channeldata[1].join(", ")}\n"
        end
        begin
          Slack.chat_postMessage username: "#{@mumbleserver_username}", channel: data['user'], text: "#{usermessage}"
        rescue
        end
      end
    end
  end
  def start
    @cli.connect
    sleep(1)
    @client.start
  end
end

client = MumbleSlack.new
client.start

