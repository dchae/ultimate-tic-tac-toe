require 'sinatra'
require 'tilt/erubis'

require_relative 'db_handler'
require_relative 'tictactoe'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, escape_html: true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'db_handler'
  also_reload 'tictactoe.rb'
end

before do
  session[:messages] ||= []
  @db = DatabaseHandler.new(logger)
  session[:game] ||= TTTGame.new('Player')
end

helpers do
  def add_message(msg)
    session[:messages] << msg
  end
end

get '/' do
  redirect '/play'
end

get '/play' do
  @game = session[:game]
  @board = @game.board
  erb :play
end

post '/play' do
  # set variables
  user_move = params[:key].to_i
  @game = session[:game]
  @board = @game.board

  # determine game state and make moves
  if @game.over?
    @result = @game.result
  else
    if @game.human_turn?
      @game.human_moves(user_move)

      @game.computer_moves unless @game.over?
    end
  end

  # check again if game is over
  @result = @game.result if @game.over?

  erb :play
end

get '/new-game' do
  session[:game].reset
  redirect '/play'
end

not_found do
  # erb :not_found
  redirect '/play'
end
