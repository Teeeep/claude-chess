require_relative '../lib/game'

RSpec.describe 'En Passant' do
  let(:game) { Game.new }

  it 'allows en passant capture' do
    game.make_move('e2e4')
    game.make_move('a7a6') # Random move
    game.make_move('e4e5')
    game.make_move('d7d5') # Black pawn moves two squares next to white pawn

    # White can capture en passant
    result = game.make_move('e5d6')
    expect(result).to be true
    expect(game.board.piece_at([2, 3])).to be_a(Pawn) # White pawn on d6
    expect(game.board.empty?([3, 3])).to be true # Black pawn on d5 captured
  end

  it 'only allows en passant on next move' do
    game.make_move('e2e4')
    game.make_move('a7a6')
    game.make_move('e4e5')
    game.make_move('d7d5')
    game.make_move('a2a3') # White makes different move
    game.make_move('a6a5')

    # En passant no longer available
    result = game.make_move('e5d6')
    expect(result).to be false
  end
end
