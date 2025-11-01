require_relative 'pawn'
require_relative 'rook'
require_relative 'knight'
require_relative 'bishop'
require_relative 'queen'
require_relative 'king'

class Board
  def initialize(setup: false)
    @grid = Array.new(8) { Array.new(8) }
    setup_initial_position if setup
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

  def move_piece(from, to)
    piece = piece_at(from)
    captured = piece_at(to)

    @grid[to[0]][to[1]] = piece
    @grid[from[0]][from[1]] = nil

    captured
  end

  def find_king(color)
    @grid.each_with_index do |row, rank|
      row.each_with_index do |piece, file|
        return [rank, file] if piece.is_a?(King) && piece.color == color
      end
    end
    nil
  end

  def pieces_of_color(color)
    pieces = []
    @grid.each_with_index do |row, rank|
      row.each_with_index do |piece, file|
        pieces << [[rank, file], piece] if piece && piece.color == color
      end
    end
    pieces
  end

  def clone
    cloned = Board.new
    @grid.each_with_index do |row, rank|
      row.each_with_index do |piece, file|
        if piece
          cloned.place_piece(piece.class.new(piece.color), [rank, file])
        end
      end
    end
    cloned
  end

  private

  def setup_initial_position
    # Black pieces (rank 0 and 1)
    setup_back_rank(0, :black)
    setup_pawn_rank(1, :black)

    # White pieces (rank 6 and 7)
    setup_pawn_rank(6, :white)
    setup_back_rank(7, :white)
  end

  def setup_back_rank(rank, color)
    @grid[rank][0] = Rook.new(color)
    @grid[rank][1] = Knight.new(color)
    @grid[rank][2] = Bishop.new(color)
    @grid[rank][3] = Queen.new(color)
    @grid[rank][4] = King.new(color)
    @grid[rank][5] = Bishop.new(color)
    @grid[rank][6] = Knight.new(color)
    @grid[rank][7] = Rook.new(color)
  end

  def setup_pawn_rank(rank, color)
    8.times do |file|
      @grid[rank][file] = Pawn.new(color)
    end
  end
end
