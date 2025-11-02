require_relative 'game'
require_relative 'fen'

# Multi-agent chess AI using specialized Claude agents
# Each agent focuses on different aspects of chess strategy
class ChessAI
  attr_reader :last_recommendations, :game_phase

  def initialize
    @last_recommendations = {}
    @game_phase = nil
  end

  # Get best move for current position
  # @param game [Game] Current game state
  # @return [String] Move in algebraic notation (e.g., "e2e4")
  def get_move(game)
    # Detect current game phase
    @game_phase = detect_phase(game)

    # Get current position as FEN
    fen = FEN.export(game)

    # Get legal moves for context
    legal_moves = get_all_legal_moves(game)

    # Build context for agents
    context = build_context(game, fen, legal_moves)

    # Dispatch agents in parallel based on game phase
    @last_recommendations = dispatch_agents(context, @game_phase)

    # Coordinator synthesizes recommendations
    coordinate_decision(game, @last_recommendations, @game_phase)
  end

  # Show reasoning from last move decision
  def explain_decision
    return "No decision made yet" if @last_recommendations.empty?

    explanation = "\n" + "=" * 60 + "\n"
    explanation += "CLAUDE'S ANALYSIS (#{@game_phase.to_s.upcase})\n"
    explanation += "=" * 60 + "\n\n"

    @last_recommendations.each do |agent, recommendation|
      explanation += "#{agent.to_s.capitalize} Agent:\n"
      explanation += "  Move: #{recommendation[:move]}\n"
      explanation += "  Reasoning: #{recommendation[:reasoning]}\n\n"
    end

    explanation += "Final Decision: #{@last_recommendations[:final][:move]}\n"
    explanation += "Coordinator: #{@last_recommendations[:final][:reasoning]}\n"
    explanation += "=" * 60 + "\n"

    explanation
  end

  private

  # Detect current game phase based on material and move count
  def detect_phase(game)
    move_count = game.move_history.length
    material = count_material(game)

    # Opening: First 15 moves or both sides have most pieces
    if move_count < 30 && material[:total] >= 70
      :opening
    # Endgame: Low material (queens traded or very few pieces)
    elsif material[:total] <= 25 || (!material[:white_queen] && !material[:black_queen])
      :endgame
    else
      :midgame
    end
  end

  # Count material on the board
  def count_material(game)
    white_material = 0
    black_material = 0
    white_queen = false
    black_queen = false

    values = { pawn: 1, knight: 3, bishop: 3, rook: 5, queen: 9 }

    game.board.pieces_of_color(:white).each do |_, piece|
      next if piece.type == :king
      white_material += values[piece.type]
      white_queen = true if piece.type == :queen
    end

    game.board.pieces_of_color(:black).each do |_, piece|
      next if piece.type == :king
      black_material += values[piece.type]
      black_queen = true if piece.type == :queen
    end

    {
      white: white_material,
      black: black_material,
      total: white_material + black_material,
      white_queen: white_queen,
      black_queen: black_queen
    }
  end

  # Get all legal moves in current position
  def get_all_legal_moves(game)
    moves = []
    game.board.pieces_of_color(game.current_player).each do |pos, piece|
      legal = game.legal_moves_for(pos)
      legal.each do |to|
        # Convert to algebraic notation
        from_algebraic = position_to_algebraic(pos)
        to_algebraic = position_to_algebraic(to)
        moves << "#{from_algebraic}#{to_algebraic}"
      end
    end
    moves
  end

  # Convert [rank, file] to algebraic notation
  def position_to_algebraic(pos)
    rank, file = pos
    file_letter = ('a'.ord + file).chr
    rank_number = 8 - rank
    "#{file_letter}#{rank_number}"
  end

  # Build context string for agents
  def build_context(game, fen, legal_moves)
    material = count_material(game)

    context = {
      fen: fen,
      current_player: game.current_player,
      move_number: (game.move_history.length / 2) + 1,
      legal_moves: legal_moves,
      move_history: game.move_history.map(&:to_algebraic).join(' '),
      material: material,
      in_check: game.in_check?(game.current_player)
    }

    context
  end

  # Dispatch specialized agents based on game phase
  def dispatch_agents(context, phase)
    recommendations = {}
    legal_moves = context[:legal_moves]

    # For now, use simple evaluation heuristics
    # TODO: Replace with actual Claude agent dispatch using Task tool

    # Opening agent: Prioritize center control and development
    opening_move = evaluate_opening_moves(legal_moves, context)
    recommendations[:opening] = opening_move

    # Midgame agent: Look for tactical opportunities
    midgame_move = evaluate_midgame_moves(legal_moves, context)
    recommendations[:midgame] = midgame_move

    # Endgame agent: Focus on king activity and pawn promotion
    endgame_move = evaluate_endgame_moves(legal_moves, context)
    recommendations[:endgame] = endgame_move

    # Coordinator: Select based on game phase
    recommendations[:final] = select_best_move(recommendations, phase)

    recommendations
  end

  # Evaluate moves from opening perspective
  def evaluate_opening_moves(legal_moves, context)
    # Prioritize center moves (e4, d4, e5, d5)
    center_squares = ['e4', 'd4', 'e5', 'd5', 'c4', 'c5', 'f4', 'f5']

    center_move = legal_moves.find { |m| center_squares.include?(m[2..3]) }
    move = center_move || legal_moves.sample

    {
      move: move,
      reasoning: center_move ?
        "Control the center with #{move}" :
        "Develop pieces toward the center"
    }
  end

  # Evaluate moves from midgame perspective
  def evaluate_midgame_moves(legal_moves, context)
    # For now, random selection
    # TODO: Add capture detection, check detection, etc.
    move = legal_moves.sample

    {
      move: move,
      reasoning: "Maintain piece activity and look for tactics"
    }
  end

  # Evaluate moves from endgame perspective
  def evaluate_endgame_moves(legal_moves, context)
    # Prioritize pawn moves in endgame
    pawn_move = legal_moves.find { |m| m[0] >= 'a' && m[0] <= 'h' && m[1].to_i <= 8 }
    move = pawn_move || legal_moves.sample

    {
      move: move,
      reasoning: pawn_move ?
        "Push passed pawns toward promotion" :
        "Activate king and support pawns"
    }
  end

  # Select best move based on phase
  def select_best_move(recommendations, phase)
    case phase
    when :opening
      rec = recommendations[:opening]
      { move: rec[:move], reasoning: "Opening phase: #{rec[:reasoning]}" }
    when :midgame
      rec = recommendations[:midgame]
      { move: rec[:move], reasoning: "Midgame phase: #{rec[:reasoning]}" }
    when :endgame
      rec = recommendations[:endgame]
      { move: rec[:move], reasoning: "Endgame phase: #{rec[:reasoning]}" }
    end
  end

  # Coordinator makes final decision based on agent recommendations
  def coordinate_decision(game, recommendations, phase)
    # For now, just return the final recommendation
    # TODO: Implement actual synthesis logic
    recommendations[:final][:move]
  end
end
