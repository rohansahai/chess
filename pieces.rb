class Piece
  attr_accessor :position, :board

  ORTHOGONAL = [
    [[-1, 0]],
    [[0, 1]],
    [[1, 0]],
    [[0, -1]]
  ]
  DIAGONAL = [
    [[-1, -1]],
    [[-1, 1]],
    [[1, -1]],
    [[1, 1]]
    ]

  def initialize(position, board = nil, color = nil)
    @position = position
    @board = board
    @color = color
  end

  def valid_moves(modifiers)
    moves = []
    modifiers.each do |direction|
      direction.each do |modifier|
        new_x = modifier.first + @position.first
        new_y = modifier.last + @position.last
        new_move =  [new_x, new_y]
        break if board.off_board?(new_move) || board.my_piece?(new_move, @color)
        moves << new_move
        break if board[new_move] #will return nil if no piece
      end
    end
    moves
  end

  def moves
    raise "Stop being an asshole, make a real piece"
  end

  def evaluate_move(move)

  end

end

class SlidingPiece < Piece

  def move_dirs(directions)
    move_mods = []
    directions.each do |modifiers|
      move_mods << generate_mods(*modifiers)
    end
    move_mods
  end

  def generate_mods(modifier)
    coord_mods = []
    1.upto(7) do |multiplier|
      new_x = modifier.first * multiplier
      new_y = modifier.last * multiplier
      coord_mods << [new_x, new_y]
    end
    coord_mods
  end
end

class King < Piece
  def moves
    valid_moves(Piece::ORTHOGONAL + Piece::DIAGONAL)
  end
end

class Knight < Piece
  KNIGHT_MOVES = [
    [[1, 2]],
    [[2, 1]],
    [[1, -2]],
    [[2, -1]],
    [[-1, 2]],
    [[-2, 1]],
    [[-1, -2]],
    [[-2, -1]]
  ]

  def moves
    valid_moves(KNIGHT_MOVES)
  end
end

class Bishop < SlidingPiece

  def moves
    valid_moves(move_dirs(Piece::DIAGONAL))
  end
end

class Rook < SlidingPiece
  def moves
    valid_moves(move_dirs(Piece::ORTHOGONAL))
  end
end

class Queen < SlidingPiece
  def moves
    valid_moves(move_dirs(Piece::ORTHOGONAL + Piece::DIAGONAL))
  end
end

class Pawn < Piece

end

#
# puts "Queen:"
# p Queen.new([0,0]).moves
# puts "Bishop:"
# p Bishop.new([0,0]).moves
# puts "Rook:"
# p Rook.new([0,0]).moves
# puts "Knight:"
# p Knight.new([0,0]).moves
# puts "King:"
# p King.new([0,0]).moves

