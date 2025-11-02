require_relative 'piece'
require_relative 'pawn'
require_relative 'rook'
require_relative 'knight'
require_relative 'bishop'
require_relative 'queen'
require_relative 'king'

# FEN (Forsyth-Edwards Notation) support for chess positions
# Standard format: <pieces> <active color> <castling> <en passant> <halfmove> <fullmove>
# Example: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
class FEN
  PIECE_SYMBOLS = {
    white: { pawn: 'P', knight: 'N', bishop: 'B', rook: 'R', queen: 'Q', king: 'K' },
    black: { pawn: 'p', knight: 'n', bishop: 'b', rook: 'r', queen: 'q', king: 'k' }
  }.freeze

  # Convert a Game to FEN notation
  # @param game [Game] The game to export
  # @return [String] FEN string representing the position
  def self.export(game)
    parts = []

    # 1. Piece placement (from rank 0/black's side to rank 7/white's side)
    parts << export_piece_placement(game.board)

    # 2. Active color
    parts << (game.current_player == :white ? 'w' : 'b')

    # 3. Castling availability
    parts << export_castling_rights(game)

    # 4. En passant target square
    parts << export_en_passant(game)

    # 5. Halfmove clock (for fifty-move rule)
    parts << export_halfmove_clock(game)

    # 6. Fullmove number
    parts << export_fullmove_number(game)

    parts.join(' ')
  end

  # Load a Game from FEN notation
  # @param fen [String] FEN string to parse
  # @return [Game] New game instance with the position loaded
  def self.import(fen)
    require_relative 'game'

    parts = fen.strip.split(/\s+/)
    raise ArgumentError, "Invalid FEN: must have 6 parts" unless parts.length == 6

    piece_placement, active_color, castling, en_passant, halfmove, fullmove = parts

    # Create empty game (we'll set up the position manually)
    game = Game.new

    # Clear the board
    8.times do |rank|
      8.times do |file|
        game.board.place_piece(nil, [rank, file])
      end
    end

    # Import piece placement
    import_piece_placement(game.board, piece_placement)

    # Set active player
    game.instance_variable_set(:@current_player, active_color == 'w' ? :white : :black)

    # Set castling rights
    import_castling_rights(game, castling)

    # Set en passant target
    import_en_passant(game, en_passant)

    # Set halfmove clock
    game.instance_variable_set(:@halfmove_clock, halfmove.to_i)

    # Set fullmove number
    game.instance_variable_set(:@fullmove_number, fullmove.to_i)

    game
  end

  private

  def self.export_piece_placement(board)
    ranks = []

    # FEN starts from rank 0 (black's back rank) to rank 7 (white's back rank)
    0.upto(7) do |rank|
      rank_str = ''
      empty_count = 0

      0.upto(7) do |file|
        piece = board.piece_at([rank, file])

        if piece.nil?
          empty_count += 1
        else
          rank_str += empty_count.to_s if empty_count > 0
          empty_count = 0
          rank_str += PIECE_SYMBOLS[piece.color][piece.type]
        end
      end

      rank_str += empty_count.to_s if empty_count > 0
      ranks << rank_str
    end

    ranks.join('/')
  end

  def self.export_castling_rights(game)
    rights = game.instance_variable_get(:@castling_rights)
    castling = ''

    castling += 'K' if rights[:white_kingside]
    castling += 'Q' if rights[:white_queenside]
    castling += 'k' if rights[:black_kingside]
    castling += 'q' if rights[:black_queenside]

    castling.empty? ? '-' : castling
  end

  def self.export_en_passant(game)
    target = game.instance_variable_get(:@en_passant_target)
    return '-' unless target

    rank, file = target
    file_letter = ('a'.ord + file).chr
    rank_number = 8 - rank  # FEN uses 1-8 from white's perspective
    "#{file_letter}#{rank_number}"
  end

  def self.export_halfmove_clock(game)
    game.instance_variable_get(:@halfmove_clock).to_s
  end

  def self.export_fullmove_number(game)
    game.instance_variable_get(:@fullmove_number).to_s
  end

  def self.import_piece_placement(board, placement)
    ranks = placement.split('/')
    raise ArgumentError, "Invalid FEN: must have 8 ranks" unless ranks.length == 8

    ranks.each_with_index do |rank_str, rank|
      file = 0

      rank_str.each_char do |char|
        if char =~ /\d/
          file += char.to_i  # Skip empty squares
        else
          piece = create_piece_from_symbol(char)
          board.place_piece(piece, [rank, file])
          file += 1
        end
      end
    end
  end

  def self.create_piece_from_symbol(symbol)
    color = symbol == symbol.upcase ? :white : :black

    case symbol.downcase
    when 'p' then Pawn.new(color)
    when 'n' then Knight.new(color)
    when 'b' then Bishop.new(color)
    when 'r' then Rook.new(color)
    when 'q' then Queen.new(color)
    when 'k' then King.new(color)
    else raise ArgumentError, "Invalid piece symbol: #{symbol}"
    end
  end

  def self.import_castling_rights(game, castling)
    rights = {
      white_kingside: castling.include?('K'),
      white_queenside: castling.include?('Q'),
      black_kingside: castling.include?('k'),
      black_queenside: castling.include?('q')
    }

    game.instance_variable_set(:@castling_rights, rights)
  end

  def self.import_en_passant(game, en_passant)
    return if en_passant == '-'

    file = en_passant[0].ord - 'a'.ord
    rank = 8 - en_passant[1].to_i  # Convert from FEN (1-8) to array index (0-7)

    game.instance_variable_set(:@en_passant_target, [rank, file])
  end
end
