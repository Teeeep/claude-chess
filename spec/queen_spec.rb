require_relative '../lib/queen'
require_relative '../lib/board'
require_relative '../lib/pawn'

RSpec.describe Queen do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'combines rook and bishop movements' do
      queen = Queen.new(:white)
      board.place_piece(queen, [4, 4]) # e4
      moves = queen.possible_moves(board, [4, 4])

      # Horizontal (rook-like)
      expect(moves).to include([4, 0], [4, 7])
      # Vertical (rook-like)
      expect(moves).to include([0, 4], [7, 4])
      # Diagonal (bishop-like)
      expect(moves).to include([0, 0], [7, 7])
      expect(moves).to include([1, 7], [7, 1])
    end

    it 'stops at pieces correctly in all directions' do
      queen = Queen.new(:white)
      ally = Pawn.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(queen, [4, 4])
      board.place_piece(ally, [4, 6])   # Horizontal block
      board.place_piece(enemy, [2, 2])  # Diagonal capture

      moves = queen.possible_moves(board, [4, 4])

      # Can't pass friendly piece
      expect(moves).not_to include([4, 7])
      # Can capture enemy
      expect(moves).to include([2, 2])
      # Can't pass enemy
      expect(moves).not_to include([1, 1])
    end
  end
end
