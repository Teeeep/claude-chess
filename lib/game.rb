require_relative 'board'
require_relative 'move'

class Game
  attr_reader :board, :current_player, :move_history

  def initialize
    @board = Board.new(setup: true)
    @current_player = :white
    @move_history = []
    @halfmove_clock = 0
    @fullmove_number = 1
    @castling_rights = {
      white_kingside: true,
      white_queenside: true,
      black_kingside: true,
      black_queenside: true
    }
    @en_passant_target = nil
    @game_over = false
    @result = nil
  end

  def over?
    @game_over
  end

  def make_move(notation)
    parsed = Move.parse_algebraic(notation)

    # Handle castling separately
    if parsed[:castling]
      return perform_castling(parsed[:castling])
    end

    from = parsed[:from]
    to = parsed[:to]

    return false unless from && to

    piece = @board.piece_at(from)
    return false unless piece
    return false unless piece.color == @current_player

    # Check if move is legal
    legal_moves = legal_moves_for(from)
    return false unless legal_moves.include?(to)

    # Check for en passant
    en_passant_capture = false
    if piece.type == :pawn && to == @en_passant_target
      en_passant_capture = true
    end

    # Perform the move
    captured = @board.move_piece(from, to)

    # Handle en passant capture
    if en_passant_capture
      direction = piece.white? ? 1 : -1
      captured_pawn_pos = [to[0] + direction, to[1]]
      captured = @board.piece_at(captured_pawn_pos)
      @board.place_piece(nil, captured_pawn_pos)
    end

    # Handle promotion
    if parsed[:promotion] && piece.type == :pawn
      promote_pawn(to, parsed[:promotion])
    end

    # Record move
    move = Move.new(
      from: from,
      to: to,
      piece: piece,
      captured: captured,
      promotion: parsed[:promotion]
    )
    @move_history << move

    # Update game state
    update_castling_rights(from, piece)
    update_en_passant_target(from, to, piece)
    update_halfmove_clock(piece, captured)
    switch_player

    # Check for game end
    check_game_end

    true
  end

  def legal_moves_for(position)
    piece = @board.piece_at(position)
    return [] unless piece
    return [] unless piece.color == @current_player

    # Pass en passant target to pawns
    possible = if piece.type == :pawn
                 piece.possible_moves(@board, position, en_passant_target: @en_passant_target)
               else
                 piece.possible_moves(@board, position)
               end

    # Filter out moves that leave king in check
    possible.select do |move_to|
      !leaves_king_in_check?(position, move_to)
    end
  end

  def in_check?(color)
    king_pos = @board.find_king(color)
    return false unless king_pos

    opponent = opponent_color(color)
    @board.pieces_of_color(opponent).any? do |pos, piece|
      piece.possible_moves(@board, pos).include?(king_pos)
    end
  end

  def checkmate?(color)
    return false unless in_check?(color)
    no_legal_moves?(color)
  end

  def stalemate?(color)
    return false if in_check?(color)
    no_legal_moves?(color)
  end

  private

  def leaves_king_in_check?(from, to)
    # Clone board and make move
    test_board = @board.clone
    test_board.move_piece(from, to)

    # Find our king
    king_pos = test_board.find_king(@current_player)
    return true unless king_pos # King captured (shouldn't happen)

    # Check if any opponent piece attacks king
    opponent = opponent_color(@current_player)
    test_board.pieces_of_color(opponent).any? do |pos, piece|
      piece.possible_moves(test_board, pos).include?(king_pos)
    end
  end

  def switch_player
    @current_player = opponent_color(@current_player)
    @fullmove_number += 1 if @current_player == :white
  end

  def opponent_color(color)
    color == :white ? :black : :white
  end

  def update_castling_rights(from, piece)
    # Remove castling rights if king or rook moves
    if piece.type == :king
      if @current_player == :white
        @castling_rights[:white_kingside] = false
        @castling_rights[:white_queenside] = false
      else
        @castling_rights[:black_kingside] = false
        @castling_rights[:black_queenside] = false
      end
    elsif piece.type == :rook
      case from
      when [7, 0] then @castling_rights[:white_queenside] = false
      when [7, 7] then @castling_rights[:white_kingside] = false
      when [0, 0] then @castling_rights[:black_queenside] = false
      when [0, 7] then @castling_rights[:black_kingside] = false
      end
    end
  end

  def update_en_passant_target(from, to, piece)
    @en_passant_target = nil

    if piece.type == :pawn && (from[0] - to[0]).abs == 2
      # Pawn moved two squares, set en passant target
      direction = piece.white? ? -1 : 1
      @en_passant_target = [from[0] + direction, from[1]]
    end
  end

  def update_halfmove_clock(piece, captured)
    if piece.type == :pawn || captured
      @halfmove_clock = 0
    else
      @halfmove_clock += 1
    end
  end

  def promote_pawn(position, piece_type)
    color = @board.piece_at(position).color
    new_piece = case piece_type
                when :queen then Queen.new(color)
                when :rook then Rook.new(color)
                when :bishop then Bishop.new(color)
                when :knight then Knight.new(color)
                end
    @board.place_piece(new_piece, position)
  end

  def perform_castling(side)
    rank = @current_player == :white ? 7 : 0
    king_file = 4

    # Determine rook position and target squares
    if side == :kingside
      rook_file = 7
      king_to = 6
      rook_to = 5
      right_key = @current_player == :white ? :white_kingside : :black_kingside
    else # queenside
      rook_file = 0
      king_to = 2
      rook_to = 3
      right_key = @current_player == :white ? :white_queenside : :black_queenside
    end

    # Check castling rights
    return false unless @castling_rights[right_key]

    # Check pieces are in place
    king = @board.piece_at([rank, king_file])
    rook = @board.piece_at([rank, rook_file])
    return false unless king.is_a?(King) && rook.is_a?(Rook)

    # Check squares between are empty
    range = side == :kingside ? (5..6) : (1..3)
    range.each do |file|
      return false unless @board.empty?([rank, file])
    end

    # Check not castling out of check
    return false if in_check?(@current_player)

    # Check not castling through check
    path = side == :kingside ? [5, 6] : [2, 3]
    path.each do |file|
      # Temporarily move king to check for attacks
      @board.place_piece(king, [rank, file])
      @board.place_piece(nil, [rank, king_file])

      if in_check?(@current_player)
        # Move king back
        @board.place_piece(king, [rank, king_file])
        @board.place_piece(nil, [rank, file])
        return false
      end

      # Move king back for next check
      @board.place_piece(king, [rank, king_file])
      @board.place_piece(nil, [rank, file])
    end

    # Perform castling
    @board.place_piece(king, [rank, king_to])
    @board.place_piece(rook, [rank, rook_to])
    @board.place_piece(nil, [rank, king_file])
    @board.place_piece(nil, [rank, rook_file])

    # Record move
    move = Move.new(
      from: [rank, king_file],
      to: [rank, king_to],
      piece: king,
      castling: side
    )
    @move_history << move

    # Update rights and switch player
    update_castling_rights([rank, king_file], king)
    switch_player
    check_game_end

    true
  end

  def no_legal_moves?(color)
    @board.pieces_of_color(color).all? do |pos, piece|
      legal_moves_for(pos).empty?
    end
  end

  def check_game_end
    if checkmate?(@current_player)
      @game_over = true
      @result = "#{opponent_color(@current_player)} wins by checkmate"
    elsif stalemate?(@current_player)
      @game_over = true
      @result = "Draw by stalemate"
    elsif @halfmove_clock >= 100
      @game_over = true
      @result = "Draw by fifty-move rule"
    end
  end
end
