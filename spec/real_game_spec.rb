require 'spec_helper'
require_relative '../lib/game'

RSpec.describe "Real game replay" do
  describe "CasperT vs yeganehrad (Lichess 2025.10.26)" do
    let(:game) { Game.new }

    it "plays through complete game without errors" do
      # This is a real game from Lichess - all moves should be valid
      # [Event "rated blitz game"]
      # [Site "https://lichess.org/5a3iQAoM"]
      # [Date "2025.10.26"]
      # [White "CasperT"]
      # [Black "yeganehrad"]

      moves = [
        # 1. e4 e5
        "e2e4", "e7e5",
        # 2. f4 Nc6
        "f2f4", "b8c6",
        # 3. Nf3 exf4
        "g1f3", "e5f4",
        # 4. Bc4 Nf6
        "f1c4", "g8f6",
        # 5. e5 Qe7
        "e4e5", "d8e7",
        # 6. d4 Ne4
        "d2d4", "f6e4",
        # 7. Bxf4 d6
        "c1f4", "d7d6",
        # 8. d5 Na5
        "d4d5", "c6a5",
        # 9. Bb5+ c6
        "c4b5", "c7c6",
        # 10. dxc6 bxc6
        "d5c6", "b7c6",
        # 11. Ba4 Bd7
        "b5a4", "c8d7",
        # 12. O-O d5
        "O-O", "d6d5",
        # 13. Ng5 h6
        "f3g5", "h7h6",
        # 14. Nxe4 dxe4
        "g5e4", "d5e4",
        # 15. Nc3 Qb4
        "b1c3", "e7b4",
        # 16. a3 Qxb2
        "a2a3", "b4b2",
        # 17. Qd4 Qb7
        "d1d4", "b2b7",
        # 18. Nxe4 Qc7
        "c3e4", "b7c7",
        # 19. Nd6+ Bxd6
        "e4d6", "f8d6",
        # 20. exd6 Qd8
        "e5d6", "c7d8",
        # 21. Qxg7 Rf8
        "d4g7", "h8f8",
        # 22. Rae1+ Be6
        "a1e1", "d7e6",
        # 23. Bxh6 Kd7
        "f4h6", "e8d7",
        # 24. Rxe6 Kc8
        "e1e6", "d7c8",
        # 25. Qc3 fxe6
        "g7c3", "f7e6",
        # 26. Bxc6 Nxc6
        "a4c6", "a5c6",
        # 27. Qxc6+ Kb8
        "c3c6", "c8b8",
        # 28. d7 Rxf1+
        "d6d7", "f8f1",
        # 29. Kxf1 a6
        "g1f1", "a7a6",
        # 30. Bf4+ Ka7
        "h6f4", "b8a7",
        # 31. Be3+ Kb8
        "f4e3", "a7b8",
        # 32. Bf4+ e5
        "e3f4", "e6e5",
        # 33. Bxe5+ Ka7
        "f4e5", "b8a7",
        # 34. Bd6 Rb8
        "e5d6", "d8b8"
      ]

      moves.each_with_index do |move, index|
        move_number = (index / 2) + 1
        color = index.even? ? "White" : "Black"

        result = game.make_move(move)

        if !result
          # Print debug info if move fails
          puts "\n❌ Move #{move_number} #{color} failed: #{move}"
          puts "Current player: #{game.current_player}"
          puts "Board state:"
          print_board(game)
          puts "\nMove history: #{game.move_history.map(&:to_algebraic).join(' ')}"
        end

        expect(result).to be_truthy, "Move #{move_number} #{color} (#{move}) should be valid but was rejected"
      end

      # Verify we got through all 68 half-moves (34 full moves)
      expect(game.move_history.length).to eq(68)
    end

    it "accepts first move e2e4" do
      expect(game.make_move("e2e4")).to be_truthy
    end

    it "accepts second move e7e5 after e2e4" do
      game.make_move("e2e4")
      expect(game.make_move("e7e5")).to be_truthy
    end

    it "accepts first three moves" do
      expect(game.make_move("e2e4")).to be_truthy
      expect(game.make_move("e7e5")).to be_truthy
      expect(game.make_move("f2f4")).to be_truthy
    end

    def print_board(game)
      board = game.board
      puts "  a b c d e f g h"
      7.downto(0) do |rank|
        print "#{rank + 1} "
        0.upto(7) do |file|
          piece = board.piece_at([rank, file])
          if piece
            symbol = piece_symbol(piece)
            print "#{symbol} "
          else
            print ". "
          end
        end
        puts "#{rank + 1}"
      end
      puts "  a b c d e f g h"
    end

    def piece_symbol(piece)
      symbols = {
        white: { king: 'K', queen: 'Q', rook: 'R', bishop: 'B', knight: 'N', pawn: 'P' },
        black: { king: 'k', queen: 'q', rook: 'r', bishop: 'b', knight: 'n', pawn: 'p' }
      }
      symbols[piece.color][piece.type]
    end
  end
end
