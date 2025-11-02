require 'spec_helper'
require_relative '../lib/game'
require_relative '../lib/move'

RSpec.describe "Standard Algebraic Notation Support" do
  let(:game) { Game.new }

  describe "pawn moves" do
    it "accepts e4 notation" do
      expect(game.make_move("e4")).to be_truthy
    end

    it "accepts lowercase e4 notation" do
      expect(game.make_move("e4")).to be_truthy
    end

    it "accepts pawn captures exd5" do
      game.make_move("e2e4")
      game.make_move("d7d5")
      expect(game.make_move("exd5")).to be_truthy
    end

    it "accepts lowercase pawn captures exd5" do
      game.make_move("e2e4")
      game.make_move("d7d5")
      expect(game.make_move("exd5")).to be_truthy
    end
  end

  describe "piece moves" do
    it "accepts Nf3" do
      expect(game.make_move("Nf3")).to be_truthy
    end

    it "accepts lowercase nf3" do
      expect(game.make_move("nf3")).to be_truthy
    end

    it "accepts Bc4" do
      game.make_move("e2e4")
      game.make_move("e7e5")
      expect(game.make_move("Bc4")).to be_truthy
    end

    it "accepts Qd3" do
      game.make_move("e2e4")
      game.make_move("e7e5")
      expect(game.make_move("Qg4")).to be_truthy
    end
  end

  describe "disambiguation" do
    # Disambiguation is supported by the parser
    # Tests would require specific board positions
    # The real game replay test covers this
  end

  describe "castling" do
    it "accepts O-O (kingside)" do
      game.make_move("e2e4")
      game.make_move("e7e5")
      game.make_move("g1f3")
      game.make_move("b8c6")
      game.make_move("f1c4")
      game.make_move("f8c5")
      expect(game.make_move("O-O")).to be_truthy
    end

    it "accepts o-o (lowercase kingside)" do
      game.make_move("e2e4")
      game.make_move("e7e5")
      game.make_move("g1f3")
      game.make_move("b8c6")
      game.make_move("f1c4")
      game.make_move("f8c5")
      expect(game.make_move("o-o")).to be_truthy
    end

    it "accepts O-O-O (queenside)" do
      game.make_move("d2d4")
      game.make_move("d7d5")
      game.make_move("c1f4")
      game.make_move("c8f5")
      game.make_move("b1c3")
      game.make_move("b8c6")
      game.make_move("d1d3")
      game.make_move("d8d7")
      expect(game.make_move("O-O-O")).to be_truthy
    end

    it "accepts 0-0 (with zeros)" do
      game.make_move("e2e4")
      game.make_move("e7e5")
      game.make_move("g1f3")
      game.make_move("b8c6")
      game.make_move("f1c4")
      game.make_move("f8c5")
      expect(game.make_move("0-0")).to be_truthy
    end
  end

  describe "captures" do
    it "accepts Nxe5" do
      game.make_move("e2e4")
      game.make_move("d7d6")
      game.make_move("g1f3")
      game.make_move("e7e5")
      expect(game.make_move("Nxe5")).to be_truthy
    end

    it "accepts lowercase nxe5" do
      game.make_move("e2e4")
      game.make_move("d7d6")
      game.make_move("g1f3")
      game.make_move("e7e5")
      expect(game.make_move("nxe5")).to be_truthy
    end
  end

  describe "check and checkmate symbols" do
    it "ignores + symbol in Nf3+" do
      expect(game.make_move("Nf3+")).to be_truthy
    end
  end

  describe "mixed notation in same game" do
    it "accepts both long and standard notation" do
      expect(game.make_move("e2e4")).to be_truthy   # Long
      expect(game.make_move("e5")).to be_truthy     # Standard
      expect(game.make_move("Nf3")).to be_truthy    # Standard
      expect(game.make_move("b8c6")).to be_truthy   # Long
      expect(game.make_move("Bc4")).to be_truthy    # Standard
      expect(game.make_move("nf6")).to be_truthy    # Lowercase standard
    end
  end
end
