require "./pieces.rb"

class Board
  attr_accessor :spaces

  def initialize
    @spaces = Array.new(8) { Array.new(8) }
    populate
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
          @spaces[row][col] = Pawn.new([col, row], self, color)
        else
          @spaces[row][col] = others[color][col].new([col, row], self, color)
        end
      end
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

new_board = Board.new

new_board.spaces.each do |row|
  row.each do |tile|
    p tile.class
  end
end

