require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require_relative "program/deck"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

def starting_hands
  deck = Deck.new
  deck.shuffle
  players = [Player.new, Player.new]
  players.each do |player|
    2.times do
      player << deck.draw_card
    end
  end

  [deck, players[0], players[1]]
end

def dealer_twists?
  session[:dealer].total < 17
end

def determine_result
  player = session[:player]
  dealer = session[:dealer]
  player_score = player.total
  dealer_score = dealer.total

  if player.bust?
    result = "You have lost!"
    reason = "You have scored #{player_score}. You bust."
  elsif dealer.bust?
    result = "You won!"
    reason = "The dealer has scored #{dealer_score}. The Dealer busts."
  elsif player.total > dealer.total
    result = "You won!"
    reason = "You scored #{player_score}. The dealer scored #{dealer_score}."
  else
    result = "You lost!"
    reason = "You scored #{player_score}. The dealer scored #{dealer_score}."
  end

  [result, reason]
end

get "/" do
  erb :index
end

post "/game/new" do
  deck, player, dealer = starting_hands
  session[:deck] = deck
  session[:player] = player
  session[:dealer] = dealer
  session[:turn] = "player"

  redirect "/game/player_turn"
end

get "/game/player_turn" do
  if session[:player].bust?
    redirect "/game/game_over"
  elsif session[:turn] != "player"
    session[:message] = "It's not your turn! Stop cheating! Start over."
    redirect "/"
  else
    erb :player_turn
  end
end

post "/game/player_turn/twist" do
  session[:player] << session[:deck].draw_card
  session[:message] = "You twist and drew the #{session[:player].last}!"

  redirect "/game/player_turn"
end

post "/game/dealer_turn" do
  if session[:turn] == "player"
    session[:turn] = "dealer"
    session[:message] = "The Dealer reveals their cards!"
    erb :dealer_turn
  elsif dealer_twists?
    session[:dealer] << session[:deck].draw_card
    session[:message] = "The Dealer twists and draws the #{session[:dealer].last}!"
    erb :dealer_turn
  else
    session[:turn] = "game over"
    session[:message] = "The Dealer sticks!"
    erb :dealer_turn
  end
end

get "/game/game_over" do
  @result, @reason = determine_result

  erb :game_over
end
