#!/usr/bin/env ruby
require 'bundler'
Bundler.require

require 'rufus-scheduler'
require 'time'
require 'pp'

# The list we care about to query
BOARD_LISTS = ["Hoy"]
TRELLO_2_HIPCHAT = {
  "pbruna" => "@pbruna",
  "andresgallardof" => "@agallardo",
  "danieleugenin" => "@deugenin",
  "elizabetharriagada1" => "@earriagada",
  "vvargasit" => "@vvargas",
  "miguelein" => "@mcoa"
}

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_OAUTH_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_TOKEN']
end

class Main
  
  def self.run

    hipchat_client = HipChat::Client.new(ENV['HIPCHAT_APIv2_TOKEN'], api_version: "v2")
    scheduler = Rufus::Scheduler.new

    scheduler.cron '39 21 * * * America/Santiago' do
      board = Trello::Board.find(ENV['TRELLO_BOARD'])
      members_id_hash = Hash.new([])

      lists = board.lists.keep_if {|list| BOARD_LISTS.include? list.name }

      lists[0].cards.each do |card|
        card.member_ids.each do |mid|
          members_id_hash[mid] |= Array.new
          members_id_hash[mid] << card.id
        end
  
      end

      members_id_hash.each do |key,val|
        member = Trello::Member.find(key)
        message = "#{member.full_name} para hoy tienes las siguientes tareas:\n\n"
        val.each do |card|
          card = Trello::Card.find(card)
          message << "- #{card.name} - #{card.short_url}\n"
        end

        message << "\n(gangnamstyle)"
        hipchat_client.user(TRELLO_2_HIPCHAT[member.username]).send(message)
  
      end
    end
  end
end

if __FILE__ == $0
  Main.run
end