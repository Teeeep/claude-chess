require_relative '../lib/fen'
require_relative '../lib/game'

RSpec.describe FEN do
  describe '.export' do
    it 'exports the starting position' do
      game = Game.new
      fen = FEN.export(game)

      expect(fen).to eq('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    end

    it 'exports a position after some moves' do
      game = Game.new
      game.make_move('e2e4')
      game.make_move('e7e5')
      fen = FEN.export(game)

      # After e7e5, en passant target is e6 (black pawn moved two squares)
      expect(fen).to eq('rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2')
    end

    it 'exports castling rights correctly' do
      game = Game.new
      # Move white king to lose castling rights
      game.board.place_piece(nil, [7, 5])  # Clear f1
      game.make_move('e1f1')
      game.make_move('a7a6')
      fen = FEN.export(game)

      # White loses castling rights after king moves
      expect(fen).to include(' kq ')
    end

    it 'exports en passant target square' do
      game = Game.new
      game.make_move('e2e4')
      game.make_move('a7a6')
      game.make_move('e4e5')
      game.make_move('d7d5')  # Black pawn moves two squares
      fen = FEN.export(game)

      # En passant target should be d6
      expect(fen).to include(' d6 ')
    end

    it 'exports halfmove clock' do
      game = Game.new
      game.make_move('g1f3')
      game.make_move('b8c6')
      fen = FEN.export(game)

      # Two knight moves, no pawn moves or captures
      expect(fen).to end_with(' 2 2')
    end
  end

  describe '.import' do
    it 'imports the starting position' do
      fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
      game = FEN.import(fen)

      expect(game.current_player).to eq(:white)
      expect(game.board.piece_at([0, 4])).to be_a(King)
      expect(game.board.piece_at([0, 4]).color).to eq(:black)
      expect(game.board.piece_at([7, 4])).to be_a(King)
      expect(game.board.piece_at([7, 4]).color).to eq(:white)
    end

    it 'imports a mid-game position' do
      fen = 'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2'
      game = FEN.import(fen)

      expect(game.current_player).to eq(:white)
      expect(game.board.piece_at([3, 4])).to be_a(Pawn)  # White pawn on e4
      expect(game.board.piece_at([4, 4])).to be_a(Pawn)  # Black pawn on e5
      expect(game.board.empty?([6, 4])).to be true       # e2 is empty
    end

    it 'imports castling rights' do
      fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kq - 0 1'
      game = FEN.import(fen)

      rights = game.instance_variable_get(:@castling_rights)
      expect(rights[:white_kingside]).to be true
      expect(rights[:white_queenside]).to be false
      expect(rights[:black_kingside]).to be false
      expect(rights[:black_queenside]).to be true
    end

    it 'imports en passant target' do
      fen = 'rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2'
      game = FEN.import(fen)

      target = game.instance_variable_get(:@en_passant_target)
      expect(target).to eq([2, 3])  # d6 in array coordinates
    end

    it 'imports halfmove and fullmove numbers' do
      fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 5 10'
      game = FEN.import(fen)

      halfmove = game.instance_variable_get(:@halfmove_clock)
      fullmove = game.instance_variable_get(:@fullmove_number)

      expect(halfmove).to eq(5)
      expect(fullmove).to eq(10)
    end

    it 'raises error for invalid FEN' do
      expect { FEN.import('invalid') }.to raise_error(ArgumentError)
      expect { FEN.import('rnbqkbnr/pppppppp w KQkq - 0 1') }.to raise_error(ArgumentError)
    end

    it 'raises error for invalid piece symbols' do
      expect { FEN.import('rnbqkXnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1') }
        .to raise_error(ArgumentError, /invalid piece symbol/)
    end

    it 'raises error for wrong number of files in rank' do
      expect { FEN.import('rnbqkbnr/ppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1') }
        .to raise_error(ArgumentError, /rank.*7 squares/)
    end

    it 'raises error for invalid active color' do
      expect { FEN.import('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR x KQkq - 0 1') }
        .to raise_error(ArgumentError, /active color must be/)
    end

    it 'raises error for invalid castling rights' do
      expect { FEN.import('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KKK - 0 1') }
        .to raise_error(ArgumentError, /castling rights/)
    end

    it 'raises error for invalid en passant square' do
      expect { FEN.import('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e9 0 1') }
        .to raise_error(ArgumentError, /en passant target/)
    end

    it 'raises error for en passant on wrong rank' do
      expect { FEN.import('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e4 0 1') }
        .to raise_error(ArgumentError, /rank 3 or 6/)
    end
  end

  describe 'round-trip conversion' do
    it 'exports and imports the same position' do
      original_fen = 'rnbqkb1r/pppp1ppp/5n2/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 4 3'
      game = FEN.import(original_fen)
      exported_fen = FEN.export(game)

      expect(exported_fen).to eq(original_fen)
    end
  end
end
