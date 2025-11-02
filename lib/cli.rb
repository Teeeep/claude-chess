require_relative 'game'

class CLI
  PIECE_SYMBOLS = {
    white: { king: '♔', queen: '♕', rook: '♖', bishop: '♗', knight: '♘', pawn: '♙' },
    black: { king: '♚', queen: '♛', rook: '♜', bishop: '♝', knight: '♞', pawn: '♟' }
  }.freeze

  def initialize
    @game = Game.new
  end

  def start
    puts "\n" + "=" * 50
    puts "♔  RUBY CHESS ENGINE  ♔".center(50)
    puts "=" * 50
    puts "\nWelcome to Ruby Chess!"
    puts "Enter moves in algebraic notation (e.g., e2e4, Nf3, O-O)"
    puts "Type 'help' for commands, 'quit' to exit\n\n"

    game_loop
  end

  private

  def game_loop
    until @game.over?
      display_board
      display_status

      move = get_move

      case move
      when 'quit', 'exit'
        puts "\nThanks for playing!"
        exit
      when 'help'
        show_help
        next
      when 'history'
        show_history
        next
      when 'undo'
        puts "\nUndo not yet implemented"
        next
      else
        handle_move(move)
      end
    end

    # Game over
    display_board
    display_game_over
  end

  def display_board
    puts "\n"
    puts "    a  b  c  d  e  f  g  h"
    puts "  ┌" + "──┬" * 7 + "──┐"

    7.downto(0) do |rank|
      print "#{rank + 1} │"

      0.upto(7) do |file|
        piece = @game.board.piece_at([rank, file])
        if piece
          symbol = PIECE_SYMBOLS[piece.color][piece.type]
          print " #{symbol} "
        else
          # Checkerboard pattern
          if (rank + file).even?
            print "   "
          else
            print " · "
          end
        end
        print "│" unless file == 7
      end

      puts "│ #{rank + 1}"
      puts "  ├" + "──┼" * 7 + "──┤" unless rank == 0
    end

    puts "  └" + "──┴" * 7 + "──┘"
    puts "    a  b  c  d  e  f  g  h"
  end

  def display_status
    puts "\n#{@game.current_player.to_s.capitalize} to move"

    if @game.in_check?(@game.current_player)
      puts "⚠️  CHECK! ⚠️"
    end

    puts ""
  end

  def display_game_over
    puts "\n" + "=" * 50
    puts "GAME OVER".center(50)
    puts "=" * 50

    if @game.checkmate?(@game.current_player)
      winner = @game.current_player == :white ? :black : :white
      puts "\n🏆 #{winner.to_s.capitalize} wins by checkmate! 🏆"
    elsif @game.stalemate?(@game.current_player)
      puts "\n🤝 Draw by stalemate"
    elsif @game.result&.include?("fifty-move rule")
      puts "\n🤝 Draw by fifty-move rule"
    elsif @game.threefold_repetition?
      puts "\n🤝 Draw by threefold repetition"
    elsif @game.insufficient_material?
      puts "\n🤝 Draw by insufficient material"
    else
      puts "\n🤝 Draw"
    end

    puts "\nFinal position:"
    puts ""
  end

  def get_move
    print "Move: "
    input = gets
    return 'quit' if input.nil?  # Handle EOF (Ctrl+D) gracefully
    input.chomp.strip.downcase
  end

  def handle_move(move_notation)
    if move_notation.empty?
      puts "Please enter a move"
      return
    end

    result = @game.make_move(move_notation)

    if result
      # Move successful
      last_move = @game.move_history.last
      puts "✓ Played: #{last_move.to_algebraic}"
    else
      puts "❌ Invalid move: #{move_notation}"
      puts "Try again (or type 'help' for assistance)"
    end
  end

  def show_help
    puts "\n" + "=" * 50
    puts "COMMANDS".center(50)
    puts "=" * 50
    puts <<~HELP

    Move notation:
      - Long algebraic: e2e4, g1f3
      - Standard algebraic: Nf3, Bb5, exd5
      - Castling: O-O (kingside), O-O-O (queenside)
      - Promotion: e8Q, e8=Q

    Commands:
      help     - Show this help
      history  - Show move history
      quit     - Exit the game

    Tips:
      - Enter moves in algebraic notation
      - The game will validate your moves automatically
      - Check and checkmate are detected automatically

    HELP
  end

  def show_history
    puts "\n" + "=" * 50
    puts "MOVE HISTORY".center(50)
    puts "=" * 50

    if @game.move_history.empty?
      puts "\nNo moves yet"
    else
      puts "\n"
      @game.move_history.each_with_index do |move, index|
        if index.even?
          print "#{(index / 2) + 1}. #{move.to_algebraic}"
        else
          puts " #{move.to_algebraic}"
        end
      end
      puts "" if @game.move_history.length.odd?
    end

    puts ""
  end
end
