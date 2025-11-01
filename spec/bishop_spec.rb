require_relative '../lib/bishop'
require_relative '../lib/board'
require_relative '../lib/pawn'

RSpec.describe Bishop do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'moves diagonally in all four directions' do
      bishop = Bishop.new(:white)
      board.place_piece(bishop, [4, 4]) # e4
      moves = bishop.possible_moves(board, [4, 4])

      # Up-left diagonal
      expect(moves).to include([3, 3], [2, 2], [1, 1], [0, 0])
      # Up-right diagonal
      expect(moves).to include([3, 5], [2, 6], [1, 7])
      # Down-left diagonal
      expect(moves).to include([5, 3], [6, 2], [7, 1])
      # Down-right diagonal
      expect(moves).to include([5, 5], [6, 6], [7, 7])
    end

    it 'stops at friendly pieces' do
      bishop = Bishop.new(:white)
      ally = Pawn.new(:white)
      board.place_piece(bishop, [4, 4])
      board.place_piece(ally, [2, 2])
      moves = bishop.possible_moves(board, [4, 4])

      expect(moves).to include([3, 3])
      expect(moves).not_to include([2, 2]) # Blocked by ally
      expect(moves).not_to include([1, 1], [0, 0]) # Can't go past
    end

    it 'captures enemy pieces' do
      bishop = Bishop.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(bishop, [4, 4])
      board.place_piece(enemy, [2, 2])
      moves = bishop.possible_moves(board, [4, 4])

      expect(moves).to include([2, 2]) # Can capture
      expect(moves).not_to include([1, 1]) # Can't go past
    end
  end
end
