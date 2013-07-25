class Board
  attr_reader :player1, :player2

  def initialize()
    @grid = Array.new(8) {Array.new(8)}
  end

  def add_players(player1, player2)
    @player1 = player1
    @player2 = player2
  end

  def [](row)
    @grid[row]
  end

  def build_board

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


    unless @grid[end_row][end_col] == nil
      old_piece = @grid[end_row][end_col]
      old_piece.kill
    end

    @grid[end_row][end_col] = @grid[start_row][start_col]
    @grid[end_row][end_col].position = [end_row, end_col]
    @grid[start_row][start_col] = nil

  end

  def can_move(start_position, end_position)
    start_row, start_col = start_position

    current_piece = @grid[start_row][start_col]

    possible_moves = current_piece.poss_moves

    unless possible_moves.include?(end_position)
      raise ArgumentError, "Your piece doesn't move that way."
    end

    ## needs to have argument of poss moves once redefined
    unless current_piece.non_check_moves(possible_moves).include?(end_position)
      raise ArgumentError, "Your King would be in check in that position."
    end

  end

  def print_board
    @grid.each_with_index do |row, row_index|
      print "#{8 - row_index} |"
      row.each do |square|
        if square.nil?
          print "___"
        else
          print "_#{square.to_s}_"
        end
        print "|"
      end
      puts "\n"
    end
    puts
    puts "    A   B   C   D   E   F   G   H  "
    puts
  end

  def self.on_board?(position)
    row, col = position
    row >= 0 && row < 8 && col >= 0 && col < 8
  end

  def deep_dup
    new_board = Board.new

    new_player1 = Player.new(@player1.color, new_board)
    new_player2 = Player.new(@player2.color, new_board)


    new_board.add_players(new_player1, new_player2)

    [@player1, @player2].each_with_index do |player, index|
      new_player = index == 0 ? new_player1 : new_player2
      player.available_pieces.each do |piece|
        new_piece = piece.class.new(new_board, new_player, piece.position.dup)
        new_board[piece.position.first][piece.position.last] = new_piece
      end
    end

    new_board
  end

end


