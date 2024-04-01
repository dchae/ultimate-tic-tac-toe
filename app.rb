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
  session[:board] ||= Board.new
  session[:human] ||= Player.new('X', 'Player')
  session[:computer] ||= Player.new('O', 'Computer')
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
  @board = session[:board]
  erb :play
end

post '/play' do
  # set variables
  user_move = params[:key].to_i

  @board, @human, @computer =
    session[:board], session[:human], session[:computer]

  # need to refactor these checks
  unless @board[user_move].marker == @human.marker || @board.someone_won? ||
           @board.full?
    @board[user_move] = @human.marker

    unless @board.someone_won? || @board.full?
      @board[@board.unmarked_keys.sample] = @computer.marker
    end
  end

  if @board.someone_won? || @board.full?
    @result =
      case @board.winning_marker
      when @human.marker
        "#{@human.name} won!"
      when @computer.marker
        "#{@computer.name} won!"
      else
        "It's a tie!"
      end
  end

  erb :play
end

get '/new-game' do
  session[:board] = Board.new
  session[:human] = Player.new('X', 'Player')
  session[:computer] = Player.new('O', 'Computer')
  redirect '/play'
end

not_found do
  # erb :not_found
  redirect '/play'
end
