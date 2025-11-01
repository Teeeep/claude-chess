require_relative '../lib/rook'
require_relative '../lib/board'
require_relative '../lib/pawn'

RSpec.describe Rook do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'moves along ranks' do
      rook = Rook.new(:white)
      board.place_piece(rook, [4, 4]) # e4
      moves = rook.possible_moves(board, [4, 4])

      # Should include all squares on rank 4
      expect(moves).to include([4, 0], [4, 1], [4, 2], [4, 3])
      expect(moves).to include([4, 5], [4, 6], [4, 7])
    end

    it 'moves along files' do
      rook = Rook.new(:white)
      board.place_piece(rook, [4, 4])
      moves = rook.possible_moves(board, [4, 4])

      # Should include all squares on file 4
      expect(moves).to include([0, 4], [1, 4], [2, 4], [3, 4])
      expect(moves).to include([5, 4], [6, 4], [7, 4])
    end

    it 'stops at friendly pieces' do
      rook = Rook.new(:white)
      ally = Pawn.new(:white)
      board.place_piece(rook, [4, 4])
      board.place_piece(ally, [4, 6]) # g4
      moves = rook.possible_moves(board, [4, 4])

      expect(moves).to include([4, 5]) # f4
      expect(moves).not_to include([4, 6]) # g4 (occupied by ally)
      expect(moves).not_to include([4, 7]) # h4 (blocked)
    end

    it 'captures enemy pieces' do
      rook = Rook.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(rook, [4, 4])
      board.place_piece(enemy, [4, 6])
      moves = rook.possible_moves(board, [4, 4])

      expect(moves).to include([4, 6]) # Can capture
      expect(moves).not_to include([4, 7]) # But can't go past
    end
  end
end
