require_relative '../lib/king'
require_relative '../lib/board'
require_relative '../lib/pawn'

RSpec.describe King do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'moves one square in any direction' do
      king = King.new(:white)
      board.place_piece(king, [4, 4]) # e4
      moves = king.possible_moves(board, [4, 4])

      expected = [
        [3, 3], [3, 4], [3, 5],  # Up-left, up, up-right
        [4, 3],         [4, 5],  # Left, right
        [5, 3], [5, 4], [5, 5]   # Down-left, down, down-right
      ]

      expect(moves.sort).to eq(expected.sort)
    end

    it 'does not move to squares with friendly pieces' do
      king = King.new(:white)
      ally = Pawn.new(:white)
      board.place_piece(king, [4, 4])
      board.place_piece(ally, [3, 3])
      moves = king.possible_moves(board, [4, 4])

      expect(moves).not_to include([3, 3])
    end

    it 'can capture enemy pieces' do
      king = King.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(king, [4, 4])
      board.place_piece(enemy, [3, 3])
      moves = king.possible_moves(board, [4, 4])

      expect(moves).to include([3, 3])
    end

    it 'respects board boundaries' do
      king = King.new(:white)
      board.place_piece(king, [0, 0]) # a1 corner
      moves = king.possible_moves(board, [0, 0])

      expect(moves).to include([0, 1], [1, 0], [1, 1])
      expect(moves.length).to eq(3)
    end
  end
end
