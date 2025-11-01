class Move
  attr_reader :from, :to, :piece, :captured, :castling, :promotion, :en_passant

  def initialize(from:, to:, piece:, captured: nil, castling: nil, promotion: nil, en_passant: false)
    @from = from
    @to = to
    @piece = piece
    @captured = captured
    @castling = castling
    @promotion = promotion
    @en_passant = en_passant
  end

  def to_algebraic
    return 'O-O' if @castling == :kingside
    return 'O-O-O' if @castling == :queenside

    notation = ''

    # Add piece letter (except for pawns)
    unless @piece.type == :pawn
      notation += piece_letter(@piece.type)
    end

    # Add file if pawn capture
    if @piece.type == :pawn && @captured
      notation += file_letter(@from[1])
    end

    # Add capture symbol
    notation += 'x' if @captured

    # Add destination square
    notation += square_name(@to)

    # Add promotion
    notation += piece_letter(@promotion) if @promotion

    notation
  end

  def to_long_algebraic
    notation = square_name(@from) + square_name(@to)
    notation += piece_letter(@promotion) if @promotion
    notation
  end

  def self.parse_algebraic(notation)
    result = {}

    # Handle castling
    if notation == 'O-O' || notation == '0-0'
      return { castling: :kingside }
    elsif notation == 'O-O-O' || notation == '0-0-0'
      return { castling: :queenside }
    end

    # Long algebraic: e2e4 or e7e8q
    if notation.match?(/^[a-h][1-8][a-h][1-8][qrbn]?$/i)
      result[:from] = parse_square(notation[0..1])
      result[:to] = parse_square(notation[2..3])
      result[:promotion] = parse_piece_letter(notation[4]) if notation.length == 5
      return result
    end

    # Standard algebraic: e4, Nf3, exd5, etc.
    # Extract destination square (always last 2 chars, or last 2 before +/#)
    clean = notation.gsub(/[+#!?]/, '')
    dest = clean[-2..]
    result[:to] = parse_square(dest)

    # Extract piece type if present
    if clean[0] =~ /[KQRBN]/
      result[:piece_type] = parse_piece_letter(clean[0])
    end

    # Extract promotion if present
    if clean =~ /=[QRBN]/
      result[:promotion] = parse_piece_letter(clean[-1])
    end

    result
  end

  private

  def square_name(position)
    rank, file = position
    file_letter(file) + (8 - rank).to_s
  end

  def file_letter(file)
    ('a'..'h').to_a[file]
  end

  def piece_letter(type)
    case type
    when :king then 'K'
    when :queen then 'Q'
    when :rook then 'R'
    when :bishop then 'B'
    when :knight then 'N'
    when :pawn then ''
    end
  end

  def self.parse_square(square_str)
    file = square_str[0].ord - 'a'.ord
    rank = 8 - square_str[1].to_i
    [rank, file]
  end

  def self.parse_piece_letter(letter)
    case letter.upcase
    when 'K' then :king
    when 'Q' then :queen
    when 'R' then :rook
    when 'B' then :bishop
    when 'N' then :knight
    else nil
    end
  end
end
