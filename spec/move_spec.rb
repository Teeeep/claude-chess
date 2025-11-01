require_relative '../lib/move'
require_relative '../lib/pawn'
require_relative '../lib/knight'
require_relative '../lib/king'

RSpec.describe Move do
  describe '#initialize' do
    it 'creates a move with from, to, and piece' do
      piece = Pawn.new(:white)
      move = Move.new(from: [6, 4], to: [4, 4], piece: piece)

      expect(move.from).to eq([6, 4])
      expect(move.to).to eq([4, 4])
      expect(move.piece).to eq(piece)
    end

    it 'stores captured piece if provided' do
      piece = Pawn.new(:white)
      captured = Pawn.new(:black)
      move = Move.new(from: [4, 4], to: [3, 5], piece: piece, captured: captured)

      expect(move.captured).to eq(captured)
    end
  end

  describe '#to_algebraic' do
    it 'converts pawn move to algebraic notation' do
      piece = Pawn.new(:white)
      move = Move.new(from: [6, 4], to: [4, 4], piece: piece)

      expect(move.to_algebraic).to eq('e4')
    end

    it 'converts piece move with piece letter' do
      piece = Knight.new(:white)
      move = Move.new(from: [7, 1], to: [5, 2], piece: piece)

      expect(move.to_algebraic).to eq('Nc3')
    end

    it 'adds capture notation' do
      piece = Pawn.new(:white)
      captured = Pawn.new(:black)
      move = Move.new(from: [4, 4], to: [3, 5], piece: piece, captured: captured)

      expect(move.to_algebraic).to eq('exf5')
    end

    it 'handles castling kingside' do
      move = Move.new(from: [7, 4], to: [7, 6], piece: King.new(:white), castling: :kingside)
      expect(move.to_algebraic).to eq('O-O')
    end

    it 'handles castling queenside' do
      move = Move.new(from: [7, 4], to: [7, 2], piece: King.new(:white), castling: :queenside)
      expect(move.to_algebraic).to eq('O-O-O')
    end
  end

  describe '#to_long_algebraic' do
    it 'converts to long algebraic notation' do
      piece = Pawn.new(:white)
      move = Move.new(from: [6, 4], to: [4, 4], piece: piece)

      expect(move.to_long_algebraic).to eq('e2e4')
    end

    it 'adds promotion piece if provided' do
      piece = Pawn.new(:white)
      move = Move.new(from: [1, 4], to: [0, 4], piece: piece, promotion: :queen)

      expect(move.to_long_algebraic).to eq('e7e8Q')
    end
  end

  describe '.parse_algebraic' do
    it 'parses long algebraic notation' do
      result = Move.parse_algebraic('e2e4')
      expect(result[:from]).to eq([6, 4])
      expect(result[:to]).to eq([4, 4])
    end

    it 'parses with promotion' do
      result = Move.parse_algebraic('e7e8q')
      expect(result[:to]).to eq([0, 4])
      expect(result[:promotion]).to eq(:queen)
    end

    it 'parses standard algebraic notation for pawn' do
      result = Move.parse_algebraic('e4')
      expect(result[:to]).to eq([4, 4])
      expect(result[:piece_type]).to be_nil # Pawn implied
    end

    it 'parses standard algebraic with piece type' do
      result = Move.parse_algebraic('Nf3')
      expect(result[:to]).to eq([5, 5])
      expect(result[:piece_type]).to eq(:knight)
    end
  end
end
