require_relative '../lib/game'

RSpec.describe 'Draw Conditions' do
  let(:game) { Game.new }

  describe 'threefold repetition' do
    it 'detects draw by threefold repetition' do
      # Knights dance back and forth
      3.times do
        game.make_move('g1f3')
        game.make_move('b8c6')
        game.make_move('f3g1')
        game.make_move('c6b8')
      end

      expect(game.threefold_repetition?).to be true
    end
  end

  describe 'insufficient material' do
    it 'detects king vs king' do
      # Set up position with only kings
      game = Game.new
      # Clear the board
      8.times do |rank|
        8.times do |file|
          game.board.place_piece(nil, [rank, file])
        end
      end
      # Place only kings
      game.board.place_piece(King.new(:white), [7, 4])
      game.board.place_piece(King.new(:black), [0, 4])

      expect(game.insufficient_material?).to be true
    end

    it 'detects king and bishop vs king' do
      game = Game.new
      # Clear the board
      8.times do |rank|
        8.times do |file|
          game.board.place_piece(nil, [rank, file])
        end
      end
      # Place pieces
      game.board.place_piece(King.new(:white), [7, 4])
      game.board.place_piece(Bishop.new(:white), [7, 5])
      game.board.place_piece(King.new(:black), [0, 4])

      expect(game.insufficient_material?).to be true
    end

    it 'detects king and knight vs king' do
      game = Game.new
      # Clear the board
      8.times do |rank|
        8.times do |file|
          game.board.place_piece(nil, [rank, file])
        end
      end
      # Place pieces
      game.board.place_piece(King.new(:white), [7, 4])
      game.board.place_piece(Knight.new(:white), [7, 1])
      game.board.place_piece(King.new(:black), [0, 4])

      expect(game.insufficient_material?).to be true
    end

    it 'does not detect insufficient material with pawns' do
      game = Game.new
      # Clear the board
      8.times do |rank|
        8.times do |file|
          game.board.place_piece(nil, [rank, file])
        end
      end
      # Place pieces
      game.board.place_piece(King.new(:white), [7, 4])
      game.board.place_piece(Pawn.new(:white), [6, 4])
      game.board.place_piece(King.new(:black), [0, 4])

      expect(game.insufficient_material?).to be false
    end
  end
end
