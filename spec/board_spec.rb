require_relative '../lib/board'
require_relative '../lib/pawn'
require_relative '../lib/rook'
require_relative '../lib/king'

RSpec.describe Board do
  let(:board) { Board.new }

  describe '#initialize' do
    it 'creates empty 8x8 board' do
      expect(board.empty?([0, 0])).to be true
      expect(board.empty?([7, 7])).to be true
    end

    context 'with setup: true' do
      let(:board) { Board.new(setup: true) }

      it 'sets up initial chess position' do
        # White pieces
        expect(board.piece_at([7, 0])).to be_a(Rook)
        expect(board.piece_at([7, 4])).to be_a(King)
        expect(board.piece_at([6, 0])).to be_a(Pawn)

        # Black pieces
        expect(board.piece_at([0, 0])).to be_a(Rook)
        expect(board.piece_at([0, 4])).to be_a(King)
        expect(board.piece_at([1, 0])).to be_a(Pawn)

        # Empty middle
        expect(board.empty?([4, 4])).to be true
      end
    end
  end

  describe '#move_piece' do
    it 'moves a piece from one square to another' do
      pawn = Pawn.new(:white)
      board.place_piece(pawn, [6, 0])
      board.move_piece([6, 0], [5, 0])

      expect(board.piece_at([5, 0])).to eq(pawn)
      expect(board.empty?([6, 0])).to be true
    end

    it 'returns captured piece if any' do
      pawn = Pawn.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(pawn, [6, 0])
      board.place_piece(enemy, [5, 0])

      captured = board.move_piece([6, 0], [5, 0])
      expect(captured).to eq(enemy)
    end
  end

  describe '#find_king' do
    it 'finds the king of specified color' do
      king = King.new(:white)
      board.place_piece(king, [7, 4])

      expect(board.find_king(:white)).to eq([7, 4])
    end

    it 'returns nil if king not found' do
      expect(board.find_king(:white)).to be_nil
    end
  end

  describe '#pieces_of_color' do
    it 'returns all pieces of a given color' do
      board.place_piece(Pawn.new(:white), [6, 0])
      board.place_piece(Pawn.new(:white), [6, 1])
      board.place_piece(Pawn.new(:black), [1, 0])

      white_pieces = board.pieces_of_color(:white)
      expect(white_pieces.length).to eq(2)
    end
  end

  describe '#clone' do
    it 'creates a deep copy of the board' do
      pawn = Pawn.new(:white)
      board.place_piece(pawn, [6, 0])

      cloned = board.clone
      cloned.move_piece([6, 0], [5, 0])

      # Original unchanged
      expect(board.piece_at([6, 0])).to eq(pawn)
      # Clone changed
      expect(cloned.piece_at([5, 0])).to be_a(Pawn)
    end
  end
end
