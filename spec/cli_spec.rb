require 'spec_helper'
require_relative '../lib/cli'
require 'stringio'

RSpec.describe CLI do
  describe '#initialize' do
    context 'with player names provided' do
      it 'uses provided player names' do
        players = { white: "Alice", black: "Bob" }
        cli = CLI.new(players: players)

        expect(cli.instance_variable_get(:@players)).to eq(players)
      end
    end

    context 'with vs_claude flag' do
      it 'creates a ChessAI instance when vs_claude is true' do
        # Stub stdin to avoid prompting
        allow_any_instance_of(CLI).to receive(:gets).and_return("TestPlayer\n")

        cli = CLI.new(vs_claude: true)

        expect(cli.instance_variable_get(:@vs_claude)).to be true
        expect(cli.instance_variable_get(:@chess_ai)).to be_a(ChessAI)
      end

      it 'does not create a ChessAI instance when vs_claude is false' do
        allow_any_instance_of(CLI).to receive(:gets).and_return("Player1\n", "Player2\n")

        cli = CLI.new(vs_claude: false)

        expect(cli.instance_variable_get(:@vs_claude)).to be false
        expect(cli.instance_variable_get(:@chess_ai)).to be_nil
      end
    end

    context 'with time control' do
      it 'creates a Clock instance when time_control is provided' do
        players = { white: "Alice", black: "Bob" }
        cli = CLI.new(time_control: { initial_time: 600, increment: 5 }, players: players)

        expect(cli.instance_variable_get(:@clock)).to be_a(Clock)
      end

      it 'does not create a Clock instance when time_control is nil' do
        players = { white: "Alice", black: "Bob" }
        cli = CLI.new(players: players)

        expect(cli.instance_variable_get(:@clock)).to be_nil
      end
    end
  end

  describe '#setup_players' do
    context 'two-player mode' do
      it 'prompts for two player names' do
        cli = CLI.new(players: { white: "Dummy", black: "Dummy" })

        allow(cli).to receive(:gets).and_return("Alice\n", "Bob\n")
        allow(cli).to receive(:rand).and_return(0)  # Predictable color assignment

        players = cli.send(:setup_players, false)

        expect(players[:white]).to eq("Alice")
        expect(players[:black]).to eq("Bob")
      end

      it 'uses default names for empty input' do
        cli = CLI.new(players: { white: "Dummy", black: "Dummy" })

        allow(cli).to receive(:gets).and_return("\n", "\n")
        allow(cli).to receive(:rand).and_return(0)

        players = cli.send(:setup_players, false)

        expect(players[:white]).to eq("Player 1")
        expect(players[:black]).to eq("Player 2")
      end

      it 'randomly assigns colors' do
        cli = CLI.new(players: { white: "Dummy", black: "Dummy" })

        # Test both random outcomes - need separate calls with fresh gets
        allow(cli).to receive(:rand).and_return(0)
        allow(cli).to receive(:gets).and_return("Alice\n", "Bob\n")
        players1 = cli.send(:setup_players, false)
        expect(players1[:white]).to eq("Alice")
        expect(players1[:black]).to eq("Bob")

        allow(cli).to receive(:rand).and_return(1)
        allow(cli).to receive(:gets).and_return("Alice\n", "Bob\n")
        players2 = cli.send(:setup_players, false)
        expect(players2[:white]).to eq("Bob")
        expect(players2[:black]).to eq("Alice")
      end

      it 'handles EOF gracefully on first player name' do
        cli = CLI.new(players: { white: "Dummy", black: "Dummy" })

        allow(cli).to receive(:gets).and_return(nil)

        players = cli.send(:setup_players, false)

        expect(players[:white]).to eq("Player 1")
        expect(players[:black]).to eq("Player 2")
      end

      it 'handles EOF gracefully on second player name' do
        cli = CLI.new(players: { white: "Dummy", black: "Dummy" })

        allow(cli).to receive(:gets).and_return("Alice\n", nil)

        players = cli.send(:setup_players, false)

        expect(players[:white]).to eq("Player 1")
        expect(players[:black]).to eq("Player 2")
      end
    end

    context 'vs Claude mode' do
      it 'prompts for one player name' do
        cli = CLI.new(players: { white: "Dummy", black: "Dummy" })

        allow(cli).to receive(:gets).and_return("Alice\n")
        allow(cli).to receive(:rand).and_return(0)

        players = cli.send(:setup_players, true)

        expect(players[:white]).to eq("Alice")
        expect(players[:black]).to eq("Claude")
      end

      it 'uses default name for empty input' do
        cli = CLI.new(players: { white: "Dummy", black: "Dummy" })

        allow(cli).to receive(:gets).and_return("\n")
        allow(cli).to receive(:rand).and_return(0)

        players = cli.send(:setup_players, true)

        expect(players[:white]).to eq("Player")
        expect(players[:black]).to eq("Claude")
      end

      it 'randomly assigns colors between player and Claude' do
        cli = CLI.new(players: { white: "Dummy", black: "Dummy" })

        allow(cli).to receive(:gets).and_return("Alice\n")

        # Test both random outcomes
        allow(cli).to receive(:rand).and_return(0)
        players1 = cli.send(:setup_players, true)
        expect(players1[:white]).to eq("Alice")
        expect(players1[:black]).to eq("Claude")

        allow(cli).to receive(:rand).and_return(1)
        players2 = cli.send(:setup_players, true)
        expect(players2[:white]).to eq("Claude")
        expect(players2[:black]).to eq("Alice")
      end

      it 'handles EOF gracefully' do
        cli = CLI.new(players: { white: "Dummy", black: "Dummy" })

        allow(cli).to receive(:gets).and_return(nil)

        players = cli.send(:setup_players, true)

        expect(players[:white]).to eq("Player")
        expect(players[:black]).to eq("Claude")
      end
    end
  end

  describe '#get_move' do
    it 'prompts for move input' do
      cli = CLI.new(players: { white: "Alice", black: "Bob" })

      allow(cli).to receive(:gets).and_return("e2e4\n")
      expect(cli).to receive(:print).with("Move: ")

      move = cli.send(:get_move)
      expect(move).to eq("e2e4")
    end

    it 'handles EOF by returning quit' do
      cli = CLI.new(players: { white: "Alice", black: "Bob" })

      allow(cli).to receive(:gets).and_return(nil)

      move = cli.send(:get_move)
      expect(move).to eq('quit')
    end

    it 'strips and downcases input' do
      cli = CLI.new(players: { white: "Alice", black: "Bob" })

      allow(cli).to receive(:gets).and_return("  E2E4  \n")

      move = cli.send(:get_move)
      expect(move).to eq("e2e4")
    end
  end

  describe '#handle_move' do
    let(:cli) { CLI.new(players: { white: "Alice", black: "Bob" }) }
    let(:game) { cli.instance_variable_get(:@game) }

    it 'returns false for empty move notation' do
      expect(cli.send(:handle_move, '')).to be false
    end

    it 'returns true for valid move' do
      result = cli.send(:handle_move, 'e2e4')
      expect(result).to be true
    end

    it 'returns false for invalid move' do
      result = cli.send(:handle_move, 'invalid')
      expect(result).to be false
    end

    it 'updates game state for valid move' do
      expect {
        cli.send(:handle_move, 'e2e4')
      }.to change { game.move_history.length }.by(1)
    end
  end

  describe '#show_player_assignment' do
    it 'displays player color assignments' do
      cli = CLI.new(players: { white: "Alice", black: "Bob" })

      output = capture_stdout do
        cli.send(:show_player_assignment)
      end

      expect(output).to include("Alice plays as WHITE")
      expect(output).to include("Bob plays as BLACK")
    end
  end

  # Helper method to capture stdout
  def capture_stdout
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end
