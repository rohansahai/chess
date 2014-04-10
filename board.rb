require "./pieces.rb"
require 'colorize'
require 'debugger'

class Board
  attr_accessor :spaces, :pieces, :cursor_pos
  OPP_COLOR = {:black => :white, :white => :black}
  GRID_COLOR = {:light_black => :white, :white => :light_black}
  GRID = {
    0 => '8',
    1 => '7',
    2 => '6',
    3 => '5',
    4 => '4',
    5 => '3',
    6 => '2',
    7 => '1'
  }

  def initialize(options = {})
    @spaces = Array.new(8) { Array.new(8) }
    @pieces = {:white => [], :black => []}
    populate unless options[:empty]
    @cursor_pos = [4, 6]
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
    puts "   " + ('a'..'h').to_a.join('  ')
    square_color = :white
    @spaces.each_with_index do |row, r_idx|
      d_row = row.map.with_index do |piece, c_idx|
        if piece
          str = " #{piece.to_show} "
          str = "$#{piece.to_show}$".blink if [c_idx, r_idx] == @cursor_pos
        else
          str = '   '
          str = "$ $".blink if [c_idx, r_idx] == @cursor_pos
        end
        str
      end
      print GRID[r_idx] + ' '
      d_row.each do |space|
        print space.colorize(:background => square_color)
        square_color = GRID_COLOR[square_color]
      end
      puts ' ' + GRID[r_idx]
      square_color = GRID_COLOR[square_color]
    end
    puts "   " + ('a'..'h').to_a.join('  ')

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
      remove_piece(end_pos)
      piece.moved = true
      @spaces[end_pos.last][end_pos.first] = piece
      @spaces[start_pos.last][start_pos.first] = nil
    else
      raise InvalidMove
    end
    nil
  end

  def remove_piece(pos)
    piece = @spaces[pos.last][pos.first]
    return unless piece
    @pieces[piece.color].delete(piece)
    nil
  end

  def move_to_check?(start_pos, end_pos, color)
    dup_board = self.dup
    dup_board.remove_piece(end_pos)
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

  def blitzkrieg(color)
    modifier = {:white => -2, :black => 2}
    pawns = @pieces[color].select {|piece| piece.is_a?(Pawn)}
    pawns.each do |pawn|
      new_x = pawn.position.first
      new_y = pawn.position.last + modifier[color]
      begin
        move(pawn.position, [new_x, new_y])
      rescue InvalidMove
        next
      end
    end
  end

  def castle(color)
    coords = { :black => [[4, 0], [7, 0]], :white => [[4, 7], [7, 7]] }

    king = self[coords[color].first]
    rook = self[coords[color].last]

    return false if king.moved || rook.moved || self.in_check?(color)

    duped_board = self.dup
    begin
      duped_board.move(king.position,[(king.position.first + 1), king.position.last])
      duped_board.move([(king.position.first + 1), king.position.last],[(king.position.first + 2), king.position.last])
      # next three lines reassign grid coordinate to point to rook
          # and reassign rook internal position to new coords
      duped_board.spaces[rook.position.last][rook.position.first - 2] = duped_board.spaces[rook.position.last][rook.position.first]
      duped_board.spaces[rook.position.last][rook.position.first - 2].position = rook.position
      duped_board.spaces[rook.position.last][rook.position.first] = nil
      raise InvalidMove if duped_board.in_check?(color)
    rescue InvalidMove
      return false
    end

    self.move(king.position,[(king.position.first + 1), king.position.last])
    self.move(king.position,[(king.position.first + 1), king.position.last])

    self.spaces[rook.position.last][rook.position.first - 2] = self.spaces[rook.position.last][rook.position.first]
    self.spaces[rook.position.last][rook.position.first - 2].position = rook.position
    self.spaces[rook.position.last][rook.position.first] = nil

    true
  end

end

class OffBoardException < RuntimeError
end

class InvalidMove < RuntimeError
end

