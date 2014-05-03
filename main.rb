#!/usr/bin/env ruby
require 'bundler'
Bundler.require

require 'time'
require 'pp'
require 'dedupe'

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_OAUTH_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_TOKEN']
end