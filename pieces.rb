class Piece
  attr_accessor :position, :board

  def initialize(position, board, color)
    @position = position
    @board = board
    @color = color
  end

  def moves(directions)
    moves = []
    directions.each do |direction|
      direction.each do |modifier|
        new_x = modifier.first + @position.first
        new_y = modifier.last + @position.last
        new_move =  [new_x, new_y]
        # moves << new_move
  #       break if @board[new_move].occupied
      end
    end
    moves
  end
end

class SlidingPiece < Piece
  ORTHOGONAL = [
    [-1, 0],
    [0, 1],
    [1, 0],
    [0, -1]
  ]
  DIAGONAL = [
    [-1, -1],
    [-1, 1],
    [1, -1],
    [1, 1]
    ]

    def initialize(position, board, color)
      super(position, board, color)
    end

    def move_dirs(directions)
      modifiers = []
      directions.each do |modifier|
        1.upto(7) do |multiplier|
          new_x = modifier.first * multiplier
          new_y = modifier.last * multiplier
          modifiers << [new_x, new_y]
        end
      end
      modifiers
    end
end

class Bishop < SlidingPiece
  def move_dirs
    super(SlidingPiece::DIAGONAL)
  end
end

class Rook < SlidingPiece
  def move_dirs
    super(SlidingPiece::ORTHOGONAL)
  end
end

class Queen < SlidingPiece
  def move_dirs
    super(SlidingPiece::ORTHOGONAL + SlidingPiece::DIAGONAL)
  end
end

p Queen.new([0,0]).move_dirs
p Bishop.new([0,0]).move_dirs
p Rook.new([0,0]).move_dirs