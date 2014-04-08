require "./pieces.rb"

class Board
  attr_accessor :spaces, :pieces
  OPP_COLOR = {:black => :white, :white => :black}

  def initialize(options = {})
    @spaces = Array.new(8) { Array.new(8) }
    @pieces = {:white => [], :black => []}
    populate unless options[:empty]
  end

  def populate
    piece_sets = { 0 => :other, 1 => :pawns, 6 => :pawns, 7 => :other }
    colors = { 0 => :black, 1 => :black, 6 => :white, 7 => :white }
    others = {
      black: {
        0 => Rook,
        1 => Knight,
        2 => Bishop,
        3 => Queen,
        4 => King,
        5 => Bishop,
        6 => Knight,
        7 => Rook
      },
      white: {
        0 => Rook,
        1 => Knight,
        2 => Bishop,
        3 => King,
        4 => Queen,
        5 => Bishop,
        6 => Knight,
        7 => Rook
      }
    }

    [0, 1, 6, 7].each do |row|
      @spaces[row].each_index do |col|
        color = colors[row]
        if piece_sets[row] == :pawns
          pawn = Pawn.new([col, row], self, color)
          @spaces[row][col] = pawn
          @pieces[color] << pawn
        else
          piece = others[color][col].new([col, row], self, color)
          @spaces[row][col] = piece
          @pieces[color] << piece
        end
      end
    end

  end

  def dup
    dup_board = self.class.new({empty: true})

    @pieces[:white].each do |piece_to_dup|
      piece = piece_to_dup.dup
      dup_board.spaces[piece.position.last][piece.position.first] = piece
      dup_board.pieces[:white] << piece
    end

    @pieces[:black].each do |piece_to_dup|
      piece = piece_to_dup.dup
      dup_board.spaces[piece.position.last][piece.position.first] = piece
      dup_board.pieces[:black] << piece
    end
    dup_board
  end

  def move(start_pos, end_pos)
    piece = self[start_pos]
    raise "No piece at start." unless piece

    if piece.moves.include?(end_pos)
      piece.position = end_pos
      @space[end_pos.last][end_pos.first] = piece
      @space[start_pos.last][start_pos.first] = nil
    else
      raise "Invalid move."
    end
    nil
  end

  def in_check?(color)
    king_pos = find_king_position(color)

    @pieces[OPP_COLOR[color]].each do |piece|
      return true if piece.moves.include?(king_pos)
    end
    false
  end

  def find_king_position(color)
    @pieces[color].each do |piece|
      return piece.position if piece.is_a?(King)
    end
  end

  def off_board?(pos)
    begin
      self[pos]
    rescue OffBoardException
      return true
    end
    false
  end

  def my_piece?(pos, color)
    if self[pos] == color
      true
    else
      false
    end
  end

  def [](pos)
    if pos.any? { |coord| coord > 7 || coord < 0 }
      raise OffBoardException
    end
    @spaces[y][x]
  end

end

# new_board = Board.new
#
# new_board.spaces.each do |row|
#   row.each do |tile|
#     next if tile.nil?
#     p tile.class
#     p tile.position
#   end
# end
# puts "DUPING BEGIN"
# dup_board = new_board.dup
# dup_board.spaces.each do |row|
#   row.each do |tile|
#     next if tile.nil?
#     p tile.class
#     p tile.position
#   end
# end

