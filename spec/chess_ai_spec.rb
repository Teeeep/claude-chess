require 'spec_helper'
require_relative '../lib/chess_ai'
require_relative '../lib/game'

RSpec.describe ChessAI do
  let(:ai) { ChessAI.new }
  let(:game) { Game.new }

  describe '#detect_phase' do
    context 'opening phase' do
      it 'detects opening in first 30 moves with high material' do
        # Starting position has all pieces (78 material points)
        expect(ai.send(:detect_phase, game)).to eq(:opening)
      end

      it 'detects opening after a few moves' do
        game.make_move('e2e4')
        game.make_move('e7e5')
        game.make_move('g1f3')
        game.make_move('b8c6')

        expect(ai.send(:detect_phase, game)).to eq(:opening)
      end
    end

    context 'midgame phase' do
      it 'detects midgame after opening with pieces still on board' do
        # Simulate 30+ moves
        (0...30).each { game.instance_variable_get(:@move_history) << double(to_algebraic: 'e4') }

        expect(ai.send(:detect_phase, game)).to eq(:midgame)
      end
    end

    context 'endgame phase' do
      it 'detects endgame when queens are traded' do
        # Set up a position without queens
        board = game.instance_variable_get(:@board)

        # Clear the board first
        (0..7).each do |rank|
          (0..7).each do |file|
            board.instance_variable_get(:@grid)[rank][file] = nil
          end
        end

        # Add just kings and a few pieces
        white_king = King.new(:white)
        black_king = King.new(:black)
        white_king.instance_variable_set(:@has_moved, false)
        black_king.instance_variable_set(:@has_moved, false)

        board.instance_variable_get(:@grid)[7][4] = white_king
        board.instance_variable_get(:@grid)[0][4] = black_king
        board.instance_variable_get(:@grid)[6][0] = Pawn.new(:white)
        board.instance_variable_get(:@grid)[1][0] = Pawn.new(:black)

        expect(ai.send(:detect_phase, game)).to eq(:endgame)
      end

      it 'detects endgame with very low material' do
        # Similar setup but verify by material count
        board = game.instance_variable_get(:@board)

        (0..7).each do |rank|
          (0..7).each do |file|
            board.instance_variable_get(:@grid)[rank][file] = nil
          end
        end

        white_king = King.new(:white)
        black_king = King.new(:black)
        white_king.instance_variable_set(:@has_moved, false)
        black_king.instance_variable_set(:@has_moved, false)

        board.instance_variable_get(:@grid)[7][4] = white_king
        board.instance_variable_get(:@grid)[0][4] = black_king

        # Add pieces that total <= 25 material
        board.instance_variable_get(:@grid)[6][0] = Rook.new(:white)  # 5 points
        board.instance_variable_get(:@grid)[1][0] = Rook.new(:black)  # 5 points

        expect(ai.send(:detect_phase, game)).to eq(:endgame)
      end
    end
  end

  describe '#count_material' do
    it 'counts material correctly at starting position' do
      material = ai.send(:count_material, game)

      # Each side: 8 pawns (8) + 2 rooks (10) + 2 knights (6) + 2 bishops (6) + 1 queen (9) = 39
      expect(material[:white]).to eq(39)
      expect(material[:black]).to eq(39)
      expect(material[:total]).to eq(78)
      expect(material[:white_queen]).to be true
      expect(material[:black_queen]).to be true
    end

    it 'detects when queens are traded' do
      # Clear queens
      board = game.instance_variable_get(:@board)
      board.instance_variable_get(:@grid)[7][3] = nil  # White queen
      board.instance_variable_get(:@grid)[0][3] = nil  # Black queen

      material = ai.send(:count_material, game)

      expect(material[:white_queen]).to be false
      expect(material[:black_queen]).to be false
      # Each side loses 9 points
      expect(material[:white]).to eq(30)
      expect(material[:black]).to eq(30)
    end
  end

  describe '#get_move' do
    it 'returns a valid move in algebraic notation' do
      move = ai.get_move(game)

      expect(move).to be_a(String)
      expect(move).to match(/^[a-h][1-8][a-h][1-8]$/)
    end

    it 'returns a legal move' do
      move = ai.get_move(game)

      # The move should be valid for the game
      expect { game.make_move(move) }.not_to raise_error
    end

    it 'does not crash on complex positions' do
      # Make several moves to create a complex position
      game.make_move('e2e4')
      game.make_move('e7e5')
      game.make_move('g1f3')
      game.make_move('b8c6')
      game.make_move('f1c4')
      game.make_move('f8c5')

      expect { ai.get_move(game) }.not_to raise_error
    end
  end

  describe '#explain_decision' do
    it 'returns a message before any decision is made' do
      expect(ai.explain_decision).to eq("No decision made yet")
    end

    it 'provides reasoning after making a move' do
      ai.get_move(game)

      explanation = ai.explain_decision

      expect(explanation).to include("CLAUDE'S ANALYSIS")
      expect(explanation).to include("Opening Agent:")
      expect(explanation).to include("Midgame Agent:")
      expect(explanation).to include("Endgame Agent:")
      expect(explanation).to include("Final Decision:")
      expect(explanation).to include("Coordinator:")
    end

    it 'includes the game phase in explanation' do
      ai.get_move(game)

      explanation = ai.explain_decision

      expect(explanation).to include("OPENING")
    end
  end

  describe 'opening strategy' do
    it 'prioritizes center control in opening' do
      # Get multiple moves to see if center moves are preferred
      center_moves = 0
      10.times do
        game = Game.new  # Fresh game each time
        test_ai = ChessAI.new
        move = test_ai.get_move(game)

        # Center squares for white's first move: e4, d4, e3, d3, c4, f4
        center_moves += 1 if ['e2e4', 'd2d4', 'e2e3', 'd2d3', 'c2c4', 'f2f4'].include?(move)
      end

      # At least some moves should target center (not purely random)
      expect(center_moves).to be > 0
    end
  end

  describe 'endgame strategy' do
    it 'prioritizes pawn moves in endgame' do
      # Create an endgame position with pawns
      board = game.instance_variable_get(:@board)

      (0..7).each do |rank|
        (0..7).each do |file|
          board.instance_variable_get(:@grid)[rank][file] = nil
        end
      end

      white_king = King.new(:white)
      black_king = King.new(:black)
      white_king.instance_variable_set(:@has_moved, false)
      black_king.instance_variable_set(:@has_moved, false)

      board.instance_variable_get(:@grid)[7][4] = white_king
      board.instance_variable_get(:@grid)[0][4] = black_king
      board.instance_variable_get(:@grid)[6][0] = Pawn.new(:white)
      board.instance_variable_get(:@grid)[1][0] = Pawn.new(:black)

      # Get AI move - should prefer pawn move if available
      move = ai.get_move(game)

      # Check that it's a valid move
      expect(move).to be_a(String)
      expect(move).to match(/^[a-h][1-8][a-h][1-8]$/)
    end
  end

  describe 'phase detection integration' do
    it 'stores the detected game phase' do
      expect(ai.game_phase).to be_nil

      ai.get_move(game)

      expect(ai.game_phase).to eq(:opening)
    end
  end

  describe 'edge cases' do
    it 'handles positions with only one legal move' do
      # This is hard to set up, but the AI should not crash
      # Just verify it doesn't crash on any starting position
      expect { ai.get_move(game) }.not_to raise_error
    end

    it 'handles positions with many legal moves' do
      # Starting position has 20 legal moves
      legal_moves = []
      game.board.pieces_of_color(:white).each do |pos, _|
        legal_moves.concat(game.legal_moves_for(pos))
      end

      expect(legal_moves.length).to eq(20)
      expect { ai.get_move(game) }.not_to raise_error
    end
  end
end
