require_relative 'piece'

class King < Piece
  def initialize(color)
    super(color, :king)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    # All eight directions, but only one square
    offsets = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1]
    ]

    offsets.each do |rank_delta, file_delta|
      new_pos = [rank + rank_delta, file + file_delta]

      next unless board.valid_position?(new_pos)

      target = board.piece_at(new_pos)
      moves << new_pos if target.nil? || target.color != @color
    end

    moves
  end
end
