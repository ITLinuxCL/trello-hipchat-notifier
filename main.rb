#!/usr/bin/env ruby
require 'bundler'
Bundler.require

require 'rufus-scheduler'
require 'time'
require 'pp'

# The list we care about to query
BOARD_LISTS = ["Doing", "Hoy", "Esperando", "Esta semana"]
TRELLO_2_HIPCHAT = {
  "pbruna" => "@pato",
  "andresgallardof" => "@andres",
  "danieleugenin" => "@daniel",
  "elizabetharriagada1" => "@elizabeth",
  "vvargasit" => "@nicolas",
  "miguelein" => "@miguel"
}

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_OAUTH_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_TOKEN']
end

class Main
  
  def self.run

    hipchat_client = HipChat::Client.new(ENV['HIPCHAT_APIv2_TOKEN'], api_version: "v2")
    scheduler = Rufus::Scheduler.new

    scheduler.cron '15 9 * * * America/Santiago' do
      board = Trello::Board.find(ENV['TRELLO_BOARD'])
      members_id_hash = Hash.new([])

      lists = board.lists.keep_if {|list| BOARD_LISTS.include? list.name }

      lists.each do |list|
        list.cards.each do |card|
          card.member_ids.each do |mid|
            members_id_hash[mid] |= Array.new
            members_id_hash[mid] << card.id
          end
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
        
        puts "Notificando a #{member.username}"
        hipchat_client.user(TRELLO_2_HIPCHAT[member.username]).send(message)
  
      end
    end
    
    scheduler.join
  end
end


Main.run
