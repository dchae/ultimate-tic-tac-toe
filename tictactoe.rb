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

  def initialize(human_name, human_marker = HUMAN_MARKER)
    @board = Board.new
    @human = Player.new(human_marker, human_name)
    @computer = Player.new(computer_marker, computer_name)
  end

  def human_marker
    HUMAN_MARKER
  end

  def computer_marker
    human.marker == 'O' ? 'X' : 'O'
  end

  def human_moves(square)
    board[square] = human.marker
  end

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def over?
    @board.someone_won? || @board.full?
  end

  def human_turn?
    number_of_moves_made = board.squares.count { |_, square| !square.unmarked? }
    number_of_moves_made.even?
  end

  def result
    case board.winning_marker
    when human.marker
      "#{human.name} won!"
    when computer.marker
      "#{computer.name} won!"
    else
      "It's a tie!"
    end
  end

  def reset
    board.reset
  end
end