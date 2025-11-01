require_relative 'piece'

class Pawn < Piece
  def initialize(color)
    super(color, :pawn)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    direction = white? ? -1 : 1
    start_rank = white? ? 6 : 1

    # Forward one square
    one_forward = [rank + direction, file]
    if board.valid_position?(one_forward) && board.empty?(one_forward)
      moves << one_forward

      # Forward two squares from starting position
      if rank == start_rank
        two_forward = [rank + (direction * 2), file]
        if board.empty?(two_forward)
          moves << two_forward
        end
      end
    end

    # Diagonal captures
    [-1, 1].each do |file_offset|
      capture_pos = [rank + direction, file + file_offset]
      if board.valid_position?(capture_pos)
        target = board.piece_at(capture_pos)
        if target && target.color != @color
          moves << capture_pos
        end
      end
    end

    moves
  end
end
