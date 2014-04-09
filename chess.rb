require './board.rb'

class Game

  def initialize
    @board = Board.new
  end

  def run
    create_players
    @board.render
    @current_player = @white

    until @board.checkmate?(@current_player.color)
      begin
        puts "#{@current_player.name}, you're up!"
        start_pos, end_pos = @current_player.get_move
        raise NachYoPeace unless @board.my_piece?(start_pos, @current_player.color)
        @board.move(start_pos, end_pos)
      rescue NachYoPeace
        puts "That's Nach Yo Peace!"
        retry
      rescue InvalidMove
        puts "That's an invalid move"
        retry
      end
      @current_player = @opposing_player[@current_player.color]

    end

    puts "#{@current_player.name}, you lose."
    puts "#{@opposing_player[@current_player.color].name}, you are the winner."

  end

  def create_players
    puts "Enter name of white player:"
    @white = HumanPlayer.new(gets.chomp, :white)
    puts "Enter name of black player:"
    @black = HumanPlayer.new(gets.chomp, :black)
    @opposing_player = {:black => @white, :white => @black}
  end
end

class HumanPlayer
  POS_FORMAT = /[a-h][1-8]/

  LETTERS_TO_NUM = {
    'a' => 0,
    'b' => 1,
    'c' => 2,
    'd' => 3,
    'e' => 4,
    'f' => 5,
    'g' => 6,
    'h' => 7
  }
  NUM_CORRECTION = {
    '8' => 0,
    '7' => 1,
    '6' => 2,
    '5' => 3,
    '4' => 4,
    '3' => 5,
    '2' => 6,
    '1' => 7
  }

  attr_accessor :name, :color
  def initialize(name, color)
    @name , @color = name, color
  end

  def get_move
    begin
      puts "Please enter the position of the piece you would like to move:"
      start_pos = gets.chomp
      raise InvalidInput unless start_pos =~ POS_FORMAT
      puts "Please enter the position you would like to move the piece to:"
      end_pos = gets.chomp
      raise InvalidInput unless end_pos =~ POS_FORMAT
    rescue InvalidInput
      puts "Those are not valid coordinates."
      retry
    end
    [parse_input(start_pos), parse_input(end_pos)]
  end

  def parse_input(pos)
    x = LETTERS_TO_NUM[pos[0]]
    y = NUM_CORRECTION[pos[1]]
    [x, y]
  end
end

class InvalidInput < RuntimeError
end

class NachYoPeace < RuntimeError
end

new_game = Game.new
new_game.run