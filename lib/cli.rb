require_relative 'game'
require_relative 'clock'
require_relative 'fen'
require_relative 'chess_ai'

class CLI
  PIECE_SYMBOLS = {
    white: { king: '♔', queen: '♕', rook: '♖', bishop: '♗', knight: '♘', pawn: '♙' },
    black: { king: '♚', queen: '♛', rook: '♜', bishop: '♝', knight: '♞', pawn: '♟' }
  }.freeze

  def initialize(time_control: nil, fen: nil, players: nil, vs_claude: false)
    @game = fen ? FEN.import(fen) : Game.new
    @clock = time_control ? Clock.new(**time_control) : nil
    @vs_claude = vs_claude
    @chess_ai = vs_claude ? ChessAI.new : nil
    @players = players || setup_players(vs_claude)
  end

  def start
    puts "\n" + "=" * 50
    puts "♔  RUBY CHESS ENGINE  ♔".center(50)
    puts "=" * 50
    puts "\nWelcome to Ruby Chess!"

    show_player_assignment

    puts "\nEnter moves in algebraic notation (e.g., e2e4, Nf3, O-O)"
    puts "Type 'help' for commands, 'quit' to exit\n\n"

    game_loop
  end

  private

  def game_loop
    @clock&.start_move(@game.current_player)

    until @game.over?
      # Check for time expiration
      if @clock && @clock.time_expired?(@game.current_player)
        @game_over_reason = :timeout
        break
      end

      display_board
      display_status

      # Check if it's Claude's turn
      if @vs_claude && @players[@game.current_player] == "Claude"
        puts "\nClaude is thinking..."
        move = @chess_ai.get_move(@game)

        if handle_move(move)
          # Show Claude's reasoning
          puts @chess_ai.explain_decision

          # Update clock
          if @clock
            @clock.stop_move
            @clock.start_move(@game.current_player)
          end
        end
      else
        # Human player's turn
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
        when 'fen'
          show_fen
          next
        when 'undo'
          puts "\nUndo not yet implemented"
          next
        else
          if handle_move(move)
            # Move was successful, update clock
            if @clock
              @clock.stop_move
              @clock.start_move(@game.current_player)
            end
          end
        end
      end
    end

    # Stop clock
    @clock&.stop_move

    # Game over
    display_board
    display_game_over
  end

  def display_board
    puts "\n"
    puts "     a   b   c   d   e   f   g   h"
    puts "   ┌───┬───┬───┬───┬───┬───┬───┬───┐"

    7.downto(0) do |rank|
      print " #{rank + 1} │"

      0.upto(7) do |file|
        piece = @game.board.piece_at([rank, file])

        # Determine square color (light or dark)
        # Bottom-right (h1) should be light: rank=0, file=7 → sum=7 (odd)
        is_light = (rank + file).odd?

        if piece
          symbol = PIECE_SYMBOLS[piece.color][piece.type]
          # Use chess.com-style colors with black outlined pieces
          if is_light
            print "\033[48;5;223m\033[30;1m #{symbol} \033[0m"  # Light square + bold black text
          else
            print "\033[48;5;180m\033[30;1m #{symbol} \033[0m"  # Dark square + bold black text
          end
        else
          # Empty square
          if is_light
            print "\033[48;5;223m   \033[0m"  # Light beige/tan
          else
            print "\033[48;5;180m   \033[0m"  # Dark tan/brown
          end
        end

        print "│" unless file == 7
      end

      puts "│ #{rank + 1}"
      puts "   ├───┼───┼───┼───┼───┼───┼───┼───┤" unless rank == 0
    end

    puts "   └───┴───┴───┴───┴───┴───┴───┴───┘"
    puts "     a   b   c   d   e   f   g   h"
  end

  def display_status
    current_player_name = @players[@game.current_player]
    puts "\n#{current_player_name}'s turn (#{@game.current_player.to_s.capitalize})"

    if @game.in_check?(@game.current_player)
      puts "⚠️  CHECK! ⚠️"
    end

    # Display clock times if enabled
    if @clock
      white_time = @clock.formatted_time(:white)
      black_time = @clock.formatted_time(:black)
      white_player = @players[:white]
      black_player = @players[:black]
      puts "\n⏱  #{white_player}: #{white_time}  |  #{black_player}: #{black_time}"

      # Warn if low on time (< 1 minute)
      if @clock.time_for(@game.current_player) < 60
        puts "⚠️  LOW ON TIME! ⚠️"
      end
    end

    puts ""
  end

  def display_game_over
    puts "\n" + "=" * 50
    puts "GAME OVER".center(50)
    puts "=" * 50

    if @game_over_reason == :timeout
      winner = @game.current_player == :white ? :black : :white
      winner_name = @players[winner]
      puts "\n🏆 #{winner_name} (#{winner.to_s.capitalize}) wins on time! 🏆"
    elsif @game.checkmate?(@game.current_player)
      winner = @game.current_player == :white ? :black : :white
      winner_name = @players[winner]
      puts "\n🏆 #{winner_name} (#{winner.to_s.capitalize}) wins by checkmate! 🏆"
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
    if move_notation.nil? || move_notation.empty?
      puts "Please enter a move"
      return false
    end

    result = @game.make_move(move_notation)

    if result
      # Move successful
      last_move = @game.move_history.last
      puts "✓ Played: #{last_move.to_algebraic}"
      true
    else
      puts "❌ Invalid move: #{move_notation}"
      puts "Try again (or type 'help' for assistance)"
      false
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
      fen      - Show current position in FEN notation
      quit     - Exit the game

    Tips:
      - Enter moves in algebraic notation
      - The game will validate your moves automatically
      - Check and checkmate are detected automatically

    HELP
  end

  def show_fen
    puts "\n" + "=" * 50
    puts "FEN NOTATION".center(50)
    puts "=" * 50

    fen = FEN.export(@game)
    puts "\n#{fen}"
    puts "\nYou can load this position later with:"
    puts "  ruby -r./lib/cli -e \"CLI.new(fen: '#{fen}').start\""

    puts ""
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

  def setup_players(vs_claude = false)
    if vs_claude
      # Playing against Claude AI
      puts "\n" + "=" * 50
      puts "PLAYER SETUP".center(50)
      puts "=" * 50
      puts ""

      print "Enter your name: "
      input = gets
      return { white: "Player", black: "Claude" } if input.nil?  # Handle EOF gracefully
      player_name = input.chomp.strip
      player_name = "Player" if player_name.empty?

      # Randomly assign colors
      if rand(2) == 0
        { white: player_name, black: "Claude" }
      else
        { white: "Claude", black: player_name }
      end
    else
      # Two-player mode
      puts "\n" + "=" * 50
      puts "PLAYER SETUP".center(50)
      puts "=" * 50
      puts ""

      print "Enter name for Player 1: "
      input = gets
      return { white: "Player 1", black: "Player 2" } if input.nil?  # Handle EOF gracefully
      player1 = input.chomp.strip
      player1 = "Player 1" if player1.empty?

      print "Enter name for Player 2: "
      input = gets
      return { white: "Player 1", black: "Player 2" } if input.nil?  # Handle EOF gracefully
      player2 = input.chomp.strip
      player2 = "Player 2" if player2.empty?

      # Randomly assign colors
      if rand(2) == 0
        { white: player1, black: player2 }
      else
        { white: player2, black: player1 }
      end
    end
  end

  def show_player_assignment
    puts "\n" + "=" * 50
    puts "COLOR ASSIGNMENT".center(50)
    puts "=" * 50
    puts "\n#{@players[:white]} plays as WHITE ♔"
    puts "#{@players[:black]} plays as BLACK ♚"
    puts ""
  end
end
