require_relative 'piece'

class Rook < Piece
  def initialize(color)
    super(color, :rook)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    # Four directions: up, down, left, right
    directions = [[-1, 0], [1, 0], [0, -1], [0, 1]]

    directions.each do |rank_delta, file_delta|
      current_rank = rank + rank_delta
      current_file = file + file_delta

      while board.valid_position?([current_rank, current_file])
        target = board.piece_at([current_rank, current_file])

        if target.nil?
          # Empty square, can move here
          moves << [current_rank, current_file]
        elsif target.color != @color
          # Enemy piece, can capture
          moves << [current_rank, current_file]
          break # Can't go past
        else
          # Friendly piece, blocked
          break
        end

        current_rank += rank_delta
        current_file += file_delta
      end
    end

    moves
  end
end
