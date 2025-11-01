require_relative '../lib/knight'
require_relative '../lib/board'
require_relative '../lib/pawn'

RSpec.describe Knight do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'moves in L-shape patterns' do
      knight = Knight.new(:white)
      board.place_piece(knight, [4, 4]) # e4
      moves = knight.possible_moves(board, [4, 4])

      expected = [
        [2, 3], [2, 5], # Two up, one left/right
        [6, 3], [6, 5], # Two down, one left/right
        [3, 2], [5, 2], # One up/down, two left
        [3, 6], [5, 6]  # One up/down, two right
      ]

      expect(moves.sort).to eq(expected.sort)
    end

    it 'can jump over pieces' do
      knight = Knight.new(:white)
      blocker = Pawn.new(:white)
      board.place_piece(knight, [4, 4])
      board.place_piece(blocker, [3, 4]) # Piece in the way
      moves = knight.possible_moves(board, [4, 4])

      # Should still reach all L-shaped squares
      expect(moves).to include([2, 3], [2, 5])
    end

    it 'does not move to squares with friendly pieces' do
      knight = Knight.new(:white)
      ally = Pawn.new(:white)
      board.place_piece(knight, [4, 4])
      board.place_piece(ally, [2, 3])
      moves = knight.possible_moves(board, [4, 4])

      expect(moves).not_to include([2, 3])
    end

    it 'can capture enemy pieces' do
      knight = Knight.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(knight, [4, 4])
      board.place_piece(enemy, [2, 3])
      moves = knight.possible_moves(board, [4, 4])

      expect(moves).to include([2, 3])
    end

    it 'respects board boundaries' do
      knight = Knight.new(:white)
      board.place_piece(knight, [0, 0]) # a1 corner
      moves = knight.possible_moves(board, [0, 0])

      # Only two possible moves from corner
      expect(moves).to include([1, 2], [2, 1])
      expect(moves.length).to eq(2)
    end
  end
end
