require_relative '../lib/clock'

RSpec.describe Clock do
  describe '#initialize' do
    it 'creates a clock with initial time' do
      clock = Clock.new(initial_time: 600)

      expect(clock.white_time).to eq(600.0)
      expect(clock.black_time).to eq(600.0)
      expect(clock.increment).to eq(0.0)
    end

    it 'creates a clock with increment' do
      clock = Clock.new(initial_time: 300, increment: 5)

      expect(clock.increment).to eq(5.0)
    end
  end

  describe '#start_move and #stop_move' do
    it 'tracks time for a move' do
      clock = Clock.new(initial_time: 600)
      clock.start_move(:white)

      sleep(0.1)  # Simulate thinking time

      time_used = clock.stop_move

      expect(time_used).to be >= 0.1
      expect(clock.white_time).to be < 600.0
      expect(clock.white_time).to be >= 599.8  # Some tolerance
    end

    it 'adds increment after move' do
      clock = Clock.new(initial_time: 600, increment: 5)
      clock.start_move(:white)

      sleep(0.1)

      clock.stop_move

      # Should deduct ~0.1 seconds and add 5 seconds increment
      expect(clock.white_time).to be > 604.0
      expect(clock.white_time).to be < 605.0
    end

    it 'does not affect opponent time' do
      clock = Clock.new(initial_time: 600)
      initial_black_time = clock.black_time

      clock.start_move(:white)
      sleep(0.1)
      clock.stop_move

      expect(clock.black_time).to eq(initial_black_time)
    end
  end

  describe '#time_for' do
    it 'returns remaining time for inactive player' do
      clock = Clock.new(initial_time: 600)
      clock.start_move(:white)

      expect(clock.time_for(:black)).to eq(600.0)
    end

    it 'returns adjusted time for active player' do
      clock = Clock.new(initial_time: 600)
      clock.start_move(:white)

      sleep(0.1)

      time = clock.time_for(:white)
      expect(time).to be < 600.0
      expect(time).to be >= 599.8
    end
  end

  describe '#time_expired?' do
    it 'returns false when time remains' do
      clock = Clock.new(initial_time: 600)

      expect(clock.time_expired?(:white)).to be false
      expect(clock.time_expired?(:black)).to be false
    end

    it 'returns true when time runs out' do
      clock = Clock.new(initial_time: 0.05)
      clock.start_move(:white)

      sleep(0.1)

      expect(clock.time_expired?(:white)).to be true
    end
  end

  describe '.format_time' do
    it 'formats seconds as M:SS' do
      expect(Clock.format_time(65)).to eq('1:05')
      expect(Clock.format_time(600)).to eq('10:00')
      expect(Clock.format_time(125)).to eq('2:05')
    end

    it 'formats hours as H:MM:SS' do
      expect(Clock.format_time(3665)).to eq('1:01:05')
      expect(Clock.format_time(7200)).to eq('2:00:00')
    end

    it 'handles zero or negative time' do
      expect(Clock.format_time(0)).to eq('0:00')
      expect(Clock.format_time(-10)).to eq('0:00')
    end
  end

  describe '#formatted_time' do
    it 'returns formatted time for a color' do
      clock = Clock.new(initial_time: 125)

      expect(clock.formatted_time(:white)).to eq('2:05')
      expect(clock.formatted_time(:black)).to eq('2:05')
    end
  end

  describe '#active?' do
    it 'returns false when not timing' do
      clock = Clock.new(initial_time: 600)

      expect(clock.active?).to be false
    end

    it 'returns true when timing a move' do
      clock = Clock.new(initial_time: 600)
      clock.start_move(:white)

      expect(clock.active?).to be true

      clock.stop_move
      expect(clock.active?).to be false
    end
  end

  describe '#active_color' do
    it 'returns nil when not timing' do
      clock = Clock.new(initial_time: 600)

      expect(clock.active_color).to be_nil
    end

    it 'returns the active color when timing' do
      clock = Clock.new(initial_time: 600)
      clock.start_move(:white)

      expect(clock.active_color).to eq(:white)

      clock.stop_move
      clock.start_move(:black)

      expect(clock.active_color).to eq(:black)
    end
  end
end
