#!/usr/bin/env ruby
require 'bundler'
Bundler.require

require 'time'
require 'pp'

# The list we care about to query
BOARD_LISTS = ["Hoy"]

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_OAUTH_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_TOKEN']
end

board = Trello::Board.find(ENV['TRELLO_BOARD'])
members_id_hash = Hash.new([])

lists = board.lists.keep_if {|list| BOARD_LISTS.include? list.name }

lists[0].cards.each do |card|=
  card.member_ids.each do |mid|
    members_id_hash[mid] |= Array.new
    members_id_hash[mid] << card.id
  end
  
end

members_id_hash.each do |key,val|
  member = Trello::Member.find(key)
  puts "#{member.username} recuerda revisar:"
  val.each do |card|
    card = Trello::Card.find(card)
    puts "#{card.name}: #{card.url}"
  end
  puts ""
  
end