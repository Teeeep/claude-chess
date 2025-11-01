require_relative 'piece'

class Queen < Piece
  def initialize(color)
    super(color, :queen)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    # Eight directions: four straight (rook) + four diagonal (bishop)
    directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1],     # Rook directions
      [-1, -1], [-1, 1], [1, -1], [1, 1]    # Bishop directions
    ]

    directions.each do |rank_delta, file_delta|
      current_rank = rank + rank_delta
      current_file = file + file_delta

      while board.valid_position?([current_rank, current_file])
        target = board.piece_at([current_rank, current_file])

        if target.nil?
          moves << [current_rank, current_file]
        elsif target.color != @color
          moves << [current_rank, current_file]
          break
        else
          break
        end

        current_rank += rank_delta
        current_file += file_delta
      end
    end

    moves
  end
end
