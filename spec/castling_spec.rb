require_relative '../lib/game'

RSpec.describe 'Castling' do
  let(:game) { Game.new }

  describe 'white kingside castling' do
    before do
      # Clear pieces between king and rook
      game.board.place_piece(nil, [7, 5]) # f1
      game.board.place_piece(nil, [7, 6]) # g1
    end

    it 'allows castling when conditions are met' do
      result = game.make_move('O-O')
      expect(result).to be true
      expect(game.board.piece_at([7, 6])).to be_a(King)
      expect(game.board.piece_at([7, 5])).to be_a(Rook)
    end

    it 'prevents castling if king has moved' do
      game.make_move('e1f1')
      game.make_move('e7e6')
      game.make_move('f1e1')
      game.make_move('e6e5')

      result = game.make_move('O-O')
      expect(result).to be false
    end

    it 'prevents castling through check' do
      # Place black rook attacking f1
      game.board.place_piece(Rook.new(:black), [0, 5])
      game.board.place_piece(nil, [1, 5])

      result = game.make_move('O-O')
      expect(result).to be false
    end

    it 'prevents castling out of check' do
      # Place black rook attacking e1
      game.board.place_piece(Rook.new(:black), [0, 4])
      game.board.place_piece(nil, [1, 4])

      result = game.make_move('O-O')
      expect(result).to be false
    end
  end

  describe 'queenside castling' do
    before do
      # Clear pieces between king and queenside rook
      game.board.place_piece(nil, [7, 1]) # b1
      game.board.place_piece(nil, [7, 2]) # c1
      game.board.place_piece(nil, [7, 3]) # d1
    end

    it 'allows queenside castling' do
      result = game.make_move('O-O-O')
      expect(result).to be true
      expect(game.board.piece_at([7, 2])).to be_a(King)
      expect(game.board.piece_at([7, 3])).to be_a(Rook)
    end
  end
end
