class Piece
  attr_accessor :position, :board

  def initialize (position, board)
    @position = position
    @board = board
  end

  def moves(move_dirs)

  end
end

class SlidingPiece

  def initialize (position, board)
    super(position, board)
  end

  def move_dirs(directions)
    move_position = []
    directions.each do |modifier|
      1.upto(7) do |multiplier|
        new_x = self.position.first + modifier.first * multiplier
        new_y = self.position.last + modifier.last * multiplier
        move_position << [new_x, new_y]
      end

    end
  end
end

class Bishop

  def move_dirs

  end

end