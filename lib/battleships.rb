require 'sinatra/base'
require 'battleships'

class BattleshipsWeb < Sinatra::Base
  set :views, Proc.new { File.join(root, "..", "views") }
  enable :sessions
  set :session_secret, 'super secret'

  get '/' do
    erb :index
  end

  get '/game/new' do
    $player_names ||= {}
    $player_one_registered ||= false
    $game ||= Game.new Player, Board
    if $player_one_registered == true
      session[:player_id] ||= :player_2
    else
      $player_one_registered = true
      session[:player_id] = :player_1
    end
    erb :'game/new'
  end

  post '/game/new' do
    # Check that a name has been entered, go to placement
    if params[:name].length >0
      $player_names[session[:player_id]] = params[:name]
      puts $player_names
      puts session[:player_id]
      redirect 'game/place'
    else
      redirect '/game/new'
    end
  end

  get '/game/place' do
    erb :'game/place'
    #Place ships. Start w/ 1 player, expand to 2
  end

  post '/game/place' do
    # Place a ship in the agreed coordinates
    # To do: error handling
    shiptype = params[:shiptype].to_sym
    direction = params[:direction].to_sym
    coords = params[:starting_coordinate].to_sym
    # To do: multiplayer
    $game.player_1.place_ship Ship.send(shiptype), coords, direction

    erb :'game/place'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
