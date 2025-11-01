class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def place_piece(piece, position)
    rank, file = position
    @grid[rank][file] = piece
  end

  def piece_at(position)
    rank, file = position
    return nil unless valid_position?(position)
    @grid[rank][file]
  end

  def valid_position?(position)
    rank, file = position
    rank.between?(0, 7) && file.between?(0, 7)
  end

  def empty?(position)
    piece_at(position).nil?
  end
end
