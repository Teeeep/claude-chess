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

    # Validate input
    return {} if notation.nil? || notation.strip.empty?

    # Normalize notation: handle both upper and lowercase
    normalized = notation.strip

    # Minimum valid move is 2 characters (e4, f3, etc.)
    return {} if normalized.length < 2

    # Handle castling (case insensitive)
    if normalized.match?(/^[oO0]-[oO0]$/i)
      return { castling: :kingside }
    elsif normalized.match?(/^[oO0]-[oO0]-[oO0]$/i)
      return { castling: :queenside }
    end

    # Long algebraic: e2e4 or e7e8q (case insensitive for promotion piece)
    if normalized.match?(/^[a-h][1-8][a-h][1-8][qrbnQRBN]?$/)
      result[:from] = parse_square(normalized[0..1])
      result[:to] = parse_square(normalized[2..3])
      result[:promotion] = parse_piece_letter(normalized[4]) if normalized.length == 5
      return result
    end

    # Standard algebraic: e4, Nf3, exd5, Nbd7, R1a3, etc.
    # Remove check/checkmate/annotation symbols and capture notation
    clean = normalized.gsub(/[+#!?x]/, '')

    # Extract promotion if present (case insensitive) - do this BEFORE extracting destination
    if clean =~ /=[QRBNqrbn]/
      promo_match = clean.match(/=([QRBNqrbn])/)
      result[:promotion] = parse_piece_letter(promo_match[1]) if promo_match
      # Remove promotion notation from clean string
      clean = clean.gsub(/=[QRBNqrbn]/, '')
    end

    # Extract destination square (always last 2 chars after removing promotion)
    dest = clean[-2..]
    result[:to] = parse_square(dest)

    # Extract piece type if present (case insensitive)
    if clean[0] =~ /[KQRBNkqrbn]/
      result[:piece_type] = parse_piece_letter(clean[0])
    end

    # Special case: pawn capture (e.g., "ed5" from "exd5")
    # If 3 chars, first char is a file, and no piece type, it's a pawn capture
    if clean.length == 3 && clean[0] =~ /[a-h]/ && !result[:piece_type]
      result[:from_file] = clean[0].ord - 'a'.ord
    end

    # Extract disambiguation (file and/or rank)
    # Examples: Nbd7 (from b-file), N5f3 (from rank 5), Qh4e1 (from h4)
    middle = clean[1..-3]  # Everything between piece letter and destination
    if middle && !middle.empty?
      # Check for file disambiguation (a-h)
      if middle =~ /[a-h]/
        file_char = middle[/[a-h]/]
        result[:from_file] = file_char.ord - 'a'.ord
      end

      # Check for rank disambiguation (1-8)
      if middle =~ /[1-8]/
        rank_char = middle[/[1-8]/]
        result[:from_rank] = 8 - rank_char.to_i
      end
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
    # Handle both uppercase and lowercase file letters
    file = square_str[0].downcase.ord - 'a'.ord
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
