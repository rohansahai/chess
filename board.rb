require "./pieces.rb"
require 'colorize'
require 'debugger'

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
      0 => Rook,
      1 => Knight,
      2 => Bishop,
      3 => Queen,
      4 => King,
      5 => Bishop,
      6 => Knight,
      7 => Rook
    }

    [0, 1, 6, 7].each do |row|
      @spaces[row].each_index do |col|
        color = colors[row]
        if piece_sets[row] == :pawns
          pawn = Pawn.new([col, row], self, color)
          @spaces[row][col] = pawn
          @pieces[color] << pawn
        else
          piece = others[col].new([col, row], self, color)
          @spaces[row][col] = piece
          @pieces[color] << piece
        end
      end
    end

  end

  def dup
    dup_board = self.class.new({empty: true})
    #can reduce these loops to single nested loop
    [:white, :black].each do |color|
      @pieces[color].each do |piece_to_dup|
        piece = piece_to_dup.dup(dup_board)
        dup_board.spaces[piece.position.last][piece.position.first] = piece
        dup_board.pieces[color] << piece
      end
    end
    dup_board
  end

  def render
    system("clear")
    puts "    " + ('a'..'h').to_a.join('   ')
    @spaces.each_with_index do |row, r_idx|
      puts ''.colorize(:background => :light_magenta)
      d_row = row.map{ |piece| piece ? " #{piece.to_show} " : ' _ ' }
      puts r_idx.to_s + "  " +  d_row.join(' ').colorize(:background => :light_magenta)
    end
    nil
  end

  def move(start_pos, end_pos)
    piece = self[start_pos]
    raise "No piece at start." unless piece
    reachable_spaces = piece.moves

    reachable_spaces.select! do |move|
      !move_to_check?(start_pos, move, piece.color)
    end

    if reachable_spaces.include?(end_pos)
      piece.position = end_pos
      @pieces[OPP_COLOR[piece.color]].delete(@spaces[end_pos.last][end_pos.first])
      @spaces[end_pos.last][end_pos.first] = piece
      @spaces[start_pos.last][start_pos.first] = nil
    else
      raise InvalidMove
    end
    self.render
    nil
  end

  def move_to_check?(start_pos, end_pos, color)
    dup_board = self.dup
    dup_board.spaces[end_pos.last][end_pos.first] = dup_board.spaces[start_pos.last][start_pos.first]
    dup_board.spaces[end_pos.last][end_pos.first].position = end_pos
    dup_board.spaces[start_pos.last][start_pos.first] = nil
    dup_board.in_check?(color)
  end

  def in_check?(color)
    king_pos = find_king_position(color)

    self.pieces[OPP_COLOR[color]].each do |piece|
      return true if piece.moves.include?(king_pos)
    end
    false
  end

  def checkmate?(color)
    @pieces[color].each do |piece|
      checkmate = piece.valid_moves.all? do |move|
        move_to_check?(piece.position, move, piece.color)
      end

      return false unless checkmate
    end
    true
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
    begin
      if self[pos].color == color
        return true
      else
        return false
      end
    rescue NoMethodError
      return false
    end
  end

  def [](pos)
    if pos.any? { |coord| coord > 7 || coord < 0 }
      raise OffBoardException
    end
    @spaces[pos.last][pos.first]
  end

end

class OffBoardException < RuntimeError
end

class InvalidMove < RuntimeError
end

# new_board = Board.new
#
# puts "we are moving the pawn"
# new_board.move([5, 6], [5, 5]) #white pawn
# puts "throw me an error"
# new_board.move([4, 1], [4, 3]) #pawn moves out of the way too late
# puts "throw me an error (final white pawn - move_to_check test)"
# new_board.move([6, 6], [6, 4]) #pawn moves into check
# puts "we are moving the queen"
# new_board.move([3, 0], [7, 4]) #black queen over a pawn
# p new_board.checkmate?(:white)

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

