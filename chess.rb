class Chess

  def run
    puts "Welcome to Chess!"

    player1 = Player.new(:white)
    player2 = Player.new(:black)
    board = Board.new()

    current_player = player1

    until false
      if player1.checkmate? || player2.checkmate?
        puts "Checkmate!"
      end

      if player1.check? || player2.check?
        puts "Check"
      end

      get_user_move

      current_player = current_player == player1 ? player2 : player1
    end
  end

end

class Player
  attr_reader :color, :available_pieces

  def initialize(color)
    @color = color
    @available_pieces = []
  end

  def add_piece(piece)
    @available_pieces << piece
  end

  def check?
    #do other player's possible moves include my king's position?
  end

  def checkmate?
    #are there any legal moves? && self.check?
  end

  def remove_piece(piece)
    @available_pieces.delete(piece)
  end
end

class Board

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    build_board
  end

  def [](row)
    @grid[row]
  end

  def build_board
    @grid = Array.new(8) {Array.new(8)}

    [1, 6].each do |row|
      (0..7).each do |col|
        @grid[row][col] = Pawn.new(self, @player1, [row, col]) if row == 1
        @grid[row][col] = Pawn.new(self, @player2, [row, col]) if row == 6
      end
    end
    @grid[0][0] = Rook.new(self, @player1, [0, 0])
    @grid[0][1] = Knight.new(self, @player1, [0, 1])
    @grid[0][2] = Bishop.new(self, @player1, [0, 2])
    @grid[0][3] = Queen.new(self, @player1, [0, 3])
    @grid[0][4] = King.new(self, @player1, [0, 4])
    @grid[0][5] = Bishop.new(self, @player1, [0, 5])
    @grid[0][6] = Knight.new(self, @player1, [0, 6])
    @grid[0][7] = Rook.new(self, @player1, [0, 7])

    @grid[7][0] = Rook.new(self, @player2, [7, 0])
    @grid[7][1] = Knight.new(self, @player2, [7, 1])
    @grid[7][2] = Bishop.new(self, @player2, [7, 2])
    @grid[7][3] = Queen.new(self, @player2, [7, 3])
    @grid[7][4] = King.new(self, @player2, [7, 4])
    @grid[7][5] = Bishop.new(self, @player2, [7, 5])
    @grid[7][6] = Knight.new(self, @player2, [7, 6])
    @grid[7][7] = Rook.new(self, @player2, [7, 7])
  end

  def move_piece(start_position, end_position)
    start_row, start_col = start_position
    end_row, end_col = end_position

    current_piece = @grid[start_row][start_col]

    if current_piece.valid_move?(end_position)
      unless @grid[end_row][end_col] == nil
        old_piece = @grid[end_row][end_col]
        old_piece.kill
      end

      @grid[end_row][end_col] = @grid[start_row][start_col]
      @grid[start_row][start_col] = nil
    else
      puts "That is an invalid move."
    end #if
  end

  def self.on_board?(position)
    row, col = position
    row >= 0 && row < 8 && col >= 0 && col < 8
  end

end

class Piece
  attr_accessor :position
  attr_reader :player

  def initialize(board, player, position)
    @board = board
    @player = player
    @player.add_piece(self)
    @position = position
  end

  def kill
    @player.remove_piece(self)
  end

  def poss_moves
  end

  def non_check_moves
  end

  def valid_move?(end_position)
    non_check_moves.include?(end_position)
  end
end

class Pawn < Piece
  def initialize(board, player, position)
    super(board, player, position)
    @original_position = position
    @orientation = (@original_position.first == 1) ? :top : :bottom
  end

  def poss_moves
    orow, ocol = @original_position
    row, col = @position
    moves = []

    drow = 1 if @orientation == :top
    drow = -1 if @orientation == :bottom

    moves << [row + drow, col] if @board[row + drow][col].nil?

    moves << [row + 2 * drow, col] if orow == row && @board[row + 2 * drow][col].nil? && @board[row + drow][col].nil?

    unless @board[row + drow][col + 1].nil? || @board[row + drow][col + 1].player == player
      moves << [row + drow, col + 1]
    end
    unless @board[row + drow][col - 1].nil? || @board[row + drow][col - 1].player == player
      moves << [row + drow, col - 1]
    end

    moves.select {|position| Board.on_board?(position)}
  end
end

class Rook < Piece
  def poss_moves
    moves = []

    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |drow, dcol|
      new_row = @position.first + drow
      new_col = @position.last + dcol

      next unless Board.on_board?([new_row, new_col])

      # the loop will stop at the last square that's still on the board, on top of an enemy piece
      # or on top of a friendly piece
      while @board[new_row][new_col].nil? && Board.on_board?([new_row + drow, new_col + dcol])
        moves << [new_row, new_col]
        new_row += drow
        new_col += dcol
      end

      if @board[new_row][new_col].nil? || @board[new_row][new_col].player != @player
        moves << [new_row, new_col]
      end
    end

    moves
  end
end

class Bishop < Piece
end

class Knight < Piece
  def poss_moves
    row, col = @position
    moves = []

    [-2, -1, 1, 2].each do |drow|
      [-2, -1, 1, 2].each do |dcol|
        next if drow.abs == dcol.abs
        moves << [row + drow, col + dcol]
      end
    end

    moves.select! {|move| Board.on_board?(move)}
    moves.select! do |move|
      move_row, move_col = move
      @board[move_row][move_col].nil? || @board[move_row][move_col].player != player
    end

    moves
  end
end

class Queen < Piece
end

class King < Piece
  def poss_moves
    row, col = @position
    moves = []

    [-1, 0, 1].each do |drow|
      [-1, 0, 1].each do |dcol|
        next if drow == 0 && dcol == 0
        moves << [row + drow, col + dcol]
      end
    end

    moves.select! {|move| Board.on_board?(move)}
    moves.select! do |move|
      move_row, move_col = move
      @board[move_row][move_col].nil? || @board[move_row][move_col].player != player
    end

    moves
  end
end

my_board = Board.new(Player.new(:white), Player.new(:black))
p my_board[7][0].poss_moves