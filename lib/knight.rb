require_relative 'piece'

class Knight < Piece
  def initialize(color)
    super(color, :knight)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    # All 8 possible L-shaped moves
    offsets = [
      [-2, -1], [-2, 1],  # Two up
      [2, -1], [2, 1],    # Two down
      [-1, -2], [1, -2],  # Two left
      [-1, 2], [1, 2]     # Two right
    ]

    offsets.each do |rank_delta, file_delta|
      new_pos = [rank + rank_delta, file + file_delta]

      next unless board.valid_position?(new_pos)

      target = board.piece_at(new_pos)
      # Can move if empty or enemy piece
      moves << new_pos if target.nil? || target.color != @color
    end

    moves
  end
end
