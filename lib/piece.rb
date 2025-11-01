class Piece
  attr_reader :color, :type

  def initialize(color, type)
    @color = color
    @type = type
  end

  def white?
    @color == :white
  end

  def black?
    @color == :black
  end

  def possible_moves(board, position)
    raise NotImplementedError, "Subclasses must implement possible_moves"
  end

  def to_s
    SYMBOLS[@color][@type]
  end

  SYMBOLS = {
    white: {
      king: '♔',
      queen: '♕',
      rook: '♖',
      bishop: '♗',
      knight: '♘',
      pawn: '♙'
    },
    black: {
      king: '♚',
      queen: '♛',
      rook: '♜',
      bishop: '♝',
      knight: '♞',
      pawn: '♟'
    }
  }.freeze
end
