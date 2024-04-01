class Board
  WINNING_LINES =
    [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + [
      [1, 5, 9],
      [3, 5, 7],
    ]
  CELL_WIDTH = 7
  CELL_HEIGHT = 3
  HZ_LINE = "#{['-' * CELL_WIDTH] * 3 * '+'}\n"
  HZ_SPACE = "#{[' ' * CELL_WIDTH] * 3 * '|'}\n"

  attr_reader :squares

  def initialize
    @squares = Hash[(1..9).map { |k| [k, Square.new] }]
  end

  def reset
    squares.each { |k, _| squares[k] = Square.new }
  end

  def [](key)
    @squares[key]
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    squares.keys.select { |k| squares[k].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    # returns winning marker or nil
    WINNING_LINES.each do |line|
      squares_in_line = squares.values_at(*line)
      return squares_in_line.first.marker if winning_line?(squares_in_line)
    end
    nil
  end

  def each_row
    @squares.each_slice(3) { |slice| yield slice }
  end

  def to_s
    hz_space = HZ_SPACE * (CELL_HEIGHT / 2)

    (0..2)
      .map do |i|
        mid =
          (0..2)
            .map { |j| squares[i * 3 + j + 1].to_s.center(CELL_WIDTH) }
            .join('|') + "\n"
        hz_space + mid + hz_space
      end
      .join(HZ_LINE)
  end

  private

  def winning_line?(squares_in_line)
    marked_squares = squares_in_line.reject(&:unmarked?)
    marked_squares.size == 3 && marked_squares.map(&:marker).uniq.size == 1
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def to_s
    marker
  end
end

class Player
  attr_reader :marker, :name

  @@count = 1

  def initialize(marker, name = "Player #{@@count}")
    @marker = marker
    @name = name
    @@count += 1
  end
end

class TTTGame
  HUMAN_MARKER = 'X'

  # COMPUTER_MARKER = "O"

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(human_marker, human_name)
    @computer = Player.new(computer_marker, computer_name)
  end

  def play
    # display_welcome_message
    main_loop
    # display_goodbye_message
  end

  private

  def human_marker
    # marker = nil
    # loop do
    #   puts "Pick a marker (1 char):"
    #   marker = gets.chomp
    #   break if marker.size == 1
    # end
    # marker
    HUMAN_MARKER
  end

  def computer_marker
    human.marker == 'O' ? 'X' : 'O'
  end

  # def human_name
  #   name = nil
  #   loop do
  #     puts "What is your name?"
  #     name = gets.chomp
  #     break unless name.empty?
  #   end
  #   name
  # end

  def computer_name
    # %W[C-3PO HAL GPT-4 Wall-E Ava TARS].sample
    'Computer'
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def main_loop
    loop do
      # display_board
      player_move

      # display_result
      break unless play_again?
      reset
      display_play_again_message
    end
  end

  # def greet_player
  #   puts "Hello, #{human.name}! Your opponent is #{computer.name}."
  # end

  # def display_welcome_message
  #   greet_player
  #   puts "Welcome to Tic Tac Toe!"
  #   puts
  # end

  # def display_goodbye_message
  #   puts "Thanks for playing Tic Tac Toe! Goodbye!"
  # end

  # def display_play_again_message
  #   puts "Let's play again!"
  #   puts
  # end

  # def display_board
  #   puts "You're a #{human.marker}. #{computer.name} is a #{computer.marker}."
  #   puts
  #   puts board
  #   puts
  # end

  # def clear
  #   system "clear"
  # end

  # def clear_screen_and_display_board
  #   clear
  #   display_board
  # end

  # def display_result
  #   clear_screen_and_display_board

  #   case board.winning_marker
  #   when human.marker
  #     puts "#{human.name} won!"
  #   when computer.marker
  #     puts "#{computer.name} won!"
  #   else
  #     puts "It's a tie!"
  #   end
  # end

  def human_moves
    puts "Choose a square: #{board.unmarked_keys.join(', ')}:"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      answer = gets.chomp.downcase
      break if answer =~ /^[yn]$/
      puts 'Sorry, not a valid choice.'
    end
    answer == 'y'
  end

  def reset
    board.reset
    clear
  end

  def human_turn?
    number_of_moves_made = board.squares.count { |_, square| !square.unmarked? }
    number_of_moves_made.even?
  end

  def current_player_moves
    human_turn? ? human_moves : computer_moves
  end
end

# game = TTTGame.new
# game.play
