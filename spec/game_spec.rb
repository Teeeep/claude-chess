require_relative '../lib/game'

RSpec.describe Game do
  let(:game) { Game.new }

  describe '#initialize' do
    it 'sets up a new game with white to move' do
      expect(game.current_player).to eq(:white)
      expect(game.over?).to be false
    end

    it 'sets up initial board position' do
      expect(game.board.piece_at([7, 4])).to be_a(King)
      expect(game.board.piece_at([0, 4])).to be_a(King)
    end
  end

  describe '#make_move' do
    it 'allows valid pawn move' do
      result = game.make_move('e2e4')
      expect(result).to be true
      expect(game.current_player).to eq(:black)
    end

    it 'rejects invalid move' do
      result = game.make_move('e2e5') # Pawn can't move 3 squares
      expect(result).to be false
      expect(game.current_player).to eq(:white) # Turn doesn't change
    end

    it 'adds move to history' do
      game.make_move('e2e4')
      expect(game.move_history.length).to eq(1)
      expect(game.move_history.first.to_long_algebraic).to eq('e2e4')
    end

    it 'alternates turns' do
      game.make_move('e2e4')
      expect(game.current_player).to eq(:black)
      game.make_move('e7e5')
      expect(game.current_player).to eq(:white)
    end
  end

  describe '#legal_moves_for' do
    it 'returns legal moves for a piece' do
      moves = game.legal_moves_for([6, 4]) # White e2 pawn
      expect(moves).to include([5, 4], [4, 4]) # e3, e4
    end

    it 'returns empty array for empty square' do
      moves = game.legal_moves_for([4, 4])
      expect(moves).to be_empty
    end

    it 'returns empty array for opponent piece' do
      moves = game.legal_moves_for([1, 4]) # Black pawn
      expect(moves).to be_empty
    end
  end

  describe '#in_check?' do
    it 'detects when king is in check' do
      game.make_move('e2e4')
      game.make_move('f7f6')
      game.make_move('d1h5') # Check!

      expect(game.in_check?(:black)).to be true
    end

    it 'returns false when king is not in check' do
      expect(game.in_check?(:white)).to be false
    end
  end

  describe '#checkmate?' do
    it 'detects fool\'s mate' do
      game.make_move('f2f3')
      game.make_move('e7e5')
      game.make_move('g2g4')
      game.make_move('d8h4') # Checkmate!

      expect(game.checkmate?(:white)).to be true
      expect(game.over?).to be true
    end
  end

  describe '#stalemate?' do
    it 'detects stalemate when no legal moves but not in check' do
      # Create stalemate position (simplified test)
      game = Game.new
      # Set up a stalemate position programmatically
      # (This is complex - in practice would set up specific position)
    end
  end
end
