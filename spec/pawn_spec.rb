require_relative '../lib/pawn'
require_relative '../lib/board'

RSpec.describe Pawn do
  let(:board) { Board.new }

  describe '#initialize' do
    it 'creates a white pawn' do
      pawn = Pawn.new(:white)
      expect(pawn.color).to eq(:white)
      expect(pawn.type).to eq(:pawn)
    end

    it 'creates a black pawn' do
      pawn = Pawn.new(:black)
      expect(pawn.color).to eq(:black)
      expect(pawn.type).to eq(:pawn)
    end
  end

  describe '#possible_moves' do
    context 'white pawn on starting square' do
      it 'can move forward one square' do
        pawn = Pawn.new(:white)
        board.place_piece(pawn, [6, 0]) # a2
        moves = pawn.possible_moves(board, [6, 0])
        expect(moves).to include([5, 0]) # a3
      end

      it 'can move forward two squares' do
        pawn = Pawn.new(:white)
        board.place_piece(pawn, [6, 0])
        moves = pawn.possible_moves(board, [6, 0])
        expect(moves).to include([4, 0]) # a4
      end

      it 'cannot move forward two if blocked' do
        pawn = Pawn.new(:white)
        blocker = Pawn.new(:black)
        board.place_piece(pawn, [6, 0])
        board.place_piece(blocker, [5, 0])
        moves = pawn.possible_moves(board, [6, 0])
        expect(moves).not_to include([4, 0])
      end
    end

    context 'white pawn not on starting square' do
      it 'can move forward one square only' do
        pawn = Pawn.new(:white)
        board.place_piece(pawn, [5, 0]) # a3
        moves = pawn.possible_moves(board, [5, 0])
        expect(moves).to include([4, 0]) # a4
        expect(moves).not_to include([3, 0]) # a5
      end
    end

    context 'white pawn captures' do
      it 'can capture diagonally left' do
        pawn = Pawn.new(:white)
        enemy = Pawn.new(:black)
        board.place_piece(pawn, [5, 1]) # b3
        board.place_piece(enemy, [4, 0]) # a4
        moves = pawn.possible_moves(board, [5, 1])
        expect(moves).to include([4, 0])
      end

      it 'can capture diagonally right' do
        pawn = Pawn.new(:white)
        enemy = Pawn.new(:black)
        board.place_piece(pawn, [5, 1]) # b3
        board.place_piece(enemy, [4, 2]) # c4
        moves = pawn.possible_moves(board, [5, 1])
        expect(moves).to include([4, 2])
      end

      it 'cannot capture own pieces' do
        pawn = Pawn.new(:white)
        ally = Pawn.new(:white)
        board.place_piece(pawn, [5, 1])
        board.place_piece(ally, [4, 0])
        moves = pawn.possible_moves(board, [5, 1])
        expect(moves).not_to include([4, 0])
      end
    end

    context 'black pawn moves in opposite direction' do
      it 'moves down the board' do
        pawn = Pawn.new(:black)
        board.place_piece(pawn, [1, 0]) # a7
        moves = pawn.possible_moves(board, [1, 0])
        expect(moves).to include([2, 0]) # a6
        expect(moves).to include([3, 0]) # a5
      end
    end
  end
end
