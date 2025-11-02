require 'spec_helper'
require_relative '../lib/cli'
require_relative '../lib/game'
require_relative '../lib/move'

RSpec.describe "CLI move parsing bug" do
  describe "lowercase notation from CLI" do
    let(:game) { Game.new }

    it "parses uppercase knight move Nf3" do
      result = Move.parse_algebraic("Nf3")
      expect(result[:piece_type]).to eq(:knight)
      expect(result[:to]).to eq([5, 5])  # f3
    end

    it "parses lowercase knight move nf3 (FIXED)" do
      result = Move.parse_algebraic("nf3")
      # Now lowercase works!
      expect(result[:piece_type]).to eq(:knight)
      expect(result[:to]).to eq([5, 5])  # f3
    end

    it "accepts e2e4 in long notation" do
      expect(game.make_move("e2e4")).to be_truthy
    end

    it "accepts e7e5 in long notation after e2e4" do
      game.make_move("e2e4")
      expect(game.make_move("e7e5")).to be_truthy
    end

    it "accepts Nf3 in standard notation (uppercase)" do
      game.make_move("e2e4")
      game.make_move("e7e5")
      expect(game.make_move("Nf3")).to be_truthy
    end

    it "accepts nf3 in lowercase standard notation (FIXED)" do
      game.make_move("e2e4")
      game.make_move("e7e5")

      # This is what CLI sends after user types "Nf3"
      # because get_move does .downcase
      result = game.make_move("nf3")

      expect(result).to be_truthy  # FIXED: now works!
    end

    it "simulates CLI flow with downcased input (FIXED)" do
      game.make_move("e2e4")
      game.make_move("e7e5")

      # Simulate what CLI does: user types "Nf3", CLI downcases it
      user_input = "Nf3"
      cli_processed = user_input.downcase.strip  # => "nf3"

      result = game.make_move(cli_processed)
      expect(result).to be_truthy  # FIXED: bug is gone!
    end
  end

  describe "castling notation case sensitivity" do
    it "accepts O-O in uppercase" do
      result = Move.parse_algebraic("O-O")
      expect(result[:castling]).to eq(:kingside)
    end

    it "accepts o-o in lowercase (FIXED)" do
      result = Move.parse_algebraic("o-o")
      expect(result[:castling]).to eq(:kingside)  # FIXED: lowercase now works!
    end
  end
end
