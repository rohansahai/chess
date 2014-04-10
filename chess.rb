require './board.rb'
require 'yaml'

class Game

  NAV = { 'j' => [-1, 0], 'k' => [0, 1], 'l' => [1, 0], 'i' => [0, -1] }
  OPP_COLOR = {:black => :white, :white => :black}

  def initialize
    @board = Board.new
  end

  def run
    system("clear")

    unless load_file
      create_players
    end
    system("clear")
    warning = nil

    until @board.checkmate?(@current_player[:color])


      begin
        input = get_move(warning)
        break unless input.is_a?(Array)
        @board.move(*input)
        warning = nil
      rescue InvalidMove
        system("clear")
        warning = "\nThat's an invalid move."
        retry
      rescue Blitzkrieg
        @board.blitzkrieg(@current_player[:color])
        warning = "\nBLIZTKRIEG!!!!"
      end
      @current_player = @players[OPP_COLOR[@current_player[:color]]]
    end

    if @board.checkmate?(@current_player[:color])
      puts "#{@current_player[:name]}, you lose."
      puts "#{@players[OPP_COLOR[@current_player[:color]]][:name]}, you are the winner."
    elsif input == 's'
      save_file
    end

    puts "Goodbye, thanks for playing chess. It's a demanding game."

  end

  def get_move(warning = nil)

    select = "\nSelect a #{@current_player[:color]} piece, #{@current_player[:name]}"
    put_piece = "\n#{@current_player[:name]}, select a position to move you're piece."

    begin
      start_pos = space_picker(select, warning)
      return start_pos unless start_pos.is_a?(Array)
      raise NachYoPeace unless @board.my_piece?(start_pos, @current_player[:color])
      end_pos = space_picker(put_piece)
      return end_pos unless end_pos.is_a?(Array)
    rescue NachYoPeace
      system("clear")
      warning = "\nThat's Nach Yo Peace!"
      retry
    end

    [start_pos, end_pos]
  end

  def save_file
    puts "What would you like to name your file?"
    file_name = gets.chomp
    File.open("#{file_name}.chess", "w") do |file|
      file.write [@board, @current_player, @players].to_yaml
    end
    puts "File saved as #{file_name}.chess in current directory."
  end

  def load_file
    puts "Would you like to load a file? (Y/N)"
    return false if gets.chomp.upcase == "N"
    puts "Enter the name of the file you would like to load."
    file_name = gets.chomp
    @board, @current_player, @players = YAML::load_file("#{file_name}.chess")
    true
  end

  def create_players
    puts "Enter name of player 1 (white pieces):"
    white = {:name => gets.chomp, :color => :white}
    puts "Enter name of player 2 (black pieces):"
    black = { :name => gets.chomp, :color => :black}
    @current_player = white
    @players = {:black => black, :white => white}
  end

  def space_picker(msg, warning = nil)
    instructions = nil

    loop do
      @board.render
      puts msg
      puts warning if warning
      puts "\n Press 'h' for help."
      puts instructions

      begin
        system("stty raw -echo")
        str = STDIN.getc
      ensure
        system("stty -raw echo")
      end

      system("clear")

      case str
      when ' '
        return @board.cursor_pos
      when 's'
        return str
      when 'q'
        return str
      when 'b'
        raise Blitzkrieg
      when 'h'
        instructions = "\r\nUse the j,k,i, and l keys to move the cursor!" \
        "\n\rPress the space bar to select a piece to move." \
        "\n\rPress it again to move your selected piece to the current cursor position." \
        "\n\rPress the s key to save you're game at any time, or q to quit!"
      end
      if NAV.include?(str)
        new_x = @board.cursor_pos[0] + NAV[str].first
        new_y = @board.cursor_pos[1] + NAV[str].last
        unless @board.off_board?([new_x, new_y])
          @board.cursor_pos = [new_x, new_y]
        end
      end

    end
  end

end

class InvalidInput < RuntimeError
end

class NachYoPeace < RuntimeError
end

class Blitzkrieg < RuntimeError
end

new_game = Game.new
new_game.run