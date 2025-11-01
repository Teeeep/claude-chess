require_relative '../lib/piece'

RSpec.describe Piece do
  describe '#initialize' do
    it 'creates a piece with color and type' do
      piece = Piece.new(:white, :pawn)
      expect(piece.color).to eq(:white)
      expect(piece.type).to eq(:pawn)
    end
  end

  describe '#white?' do
    it 'returns true for white pieces' do
      piece = Piece.new(:white, :pawn)
      expect(piece.white?).to be true
    end

    it 'returns false for black pieces' do
      piece = Piece.new(:black, :pawn)
      expect(piece.white?).to be false
    end
  end

  describe '#black?' do
    it 'returns true for black pieces' do
      piece = Piece.new(:black, :pawn)
      expect(piece.black?).to be true
    end

    it 'returns false for white pieces' do
      piece = Piece.new(:white, :pawn)
      expect(piece.black?).to be false
    end
  end

  describe '#possible_moves' do
    it 'raises NotImplementedError for base class' do
      piece = Piece.new(:white, :pawn)
      expect { piece.possible_moves(nil, [0, 0]) }.to raise_error(NotImplementedError)
    end
  end
end
