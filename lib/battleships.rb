require 'sinatra/base'
require 'battleships'

class BattleshipsWeb < Sinatra::Base
  set :views, Proc.new { File.join(root, "..", "views") }
  set :public_folder, Proc.new { File.join(root, "..", "public") }
  enable :sessions
  #set :session_secret, 'super secret'

  get '/' do
    #send_file File.join(settings.public_folder, 'index.html')
    erb :index
  end

  get '/game/new' do
    # Set up variables to store game state
    $player_names ||= {}
    $game_status ||= {}
    $game ||= Game.new Player, Board

    # Figure out who this player is
    # To do: error handling for 3rd, 4th etc. players
    # To do: enable multiple games at once
    if session.has_key?(:player_id) # Player is already set up
      'Enter a name!'
    elsif $game_status.has_key?(:player_1) # Player 2 setup
      $game_status[:player_2]=:giving_name
      session[:player_id]=:player_2
      session[:other_player]=:player_1
    else # Player 1 setup
      $game_status[:player_1]=:giving_name
      session[:player_id]=:player_1
      session[:other_player]=:player_2
    end

    # Display a name entry form
    erb :'game/new'
  end

  post '/game/new' do
    # Check that a name has been entered, go to placement
    # Note that params has unusual syntax for has_key?
    if params.has_key?('name')
      redirect '/game/new' if params[:name].length == 0
      $player_names[session[:player_id]] = params[:name]
      redirect '/game/place'
    else # Go back to name entry if no name was entered
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
    $game.send(session[:player_id]).place_ship Ship.send(shiptype), coords, direction

    erb :'game/place'
  end

  get '/game/play' do
    # Wait for both opponents to finish placement
    $game_status[session[:player_id]] = :playing
    $game_status[:whose_turn] ||= :player_1 # player 1 takes first move

    if not($game_status[:player_1]==:playing and $game_status[:player_2]==:playing)
      # Display a wait to play screen if ship placement ongoing
      erb :'game/waitToPlay'
    elsif $game.has_winner?
      #Show the game over screen if one party has won
      redirect '/game/over'
    elsif $game_status[:whose_turn] != session[:player_id]
      #Show the waiting screen if it's opponent's move
      erb :'game/waitToShoot'
    else
      #Let the player take a shot
      erb :'game/play'
    end
  end

  post '/game/play' do
    # To do: only accept shots from the current player
    # To do: error handling on shooting
    $game.send(session[:player_id]).shoot params[:coord].to_sym
    # Change whose move it is
    $game_status[:whose_turn] = session[:other_player]
    # Check win state and redirect to game over if so
    redirect '/game/over' if $game.has_winner?
    # Wait to shoot
    erb :'game/waitToShoot'
  end

  get '/game/over' do
    if $game.send(session[:player_id]).winner?
      erb :'game/overWon'
    else
      erb :'game/overLost'
    end
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end
