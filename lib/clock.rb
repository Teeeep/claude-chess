# Chess clock for tracking time controls
# Supports initial time and increment per move
class Clock
  attr_reader :white_time, :black_time, :increment

  # Create a new chess clock
  # @param initial_time [Integer] Starting time in seconds for each player
  # @param increment [Integer] Time added after each move in seconds (default: 0)
  def initialize(initial_time:, increment: 0)
    @white_time = initial_time.to_f
    @black_time = initial_time.to_f
    @increment = increment.to_f
    @active_color = nil
    @move_start_time = nil
  end

  # Start timing a move for the given color
  # @param color [Symbol] :white or :black
  def start_move(color)
    # If there was a previous move running, stop it first
    stop_move if @active_color

    @active_color = color
    @move_start_time = Time.now
  end

  # Stop timing the current move and add increment
  # @return [Float] Time used for this move in seconds
  def stop_move
    return 0.0 unless @active_color && @move_start_time

    time_used = Time.now - @move_start_time

    # Deduct time used
    if @active_color == :white
      @white_time -= time_used
    else
      @black_time -= time_used
    end

    # Add increment
    if @active_color == :white
      @white_time += @increment
    else
      @black_time += @increment
    end

    @active_color = nil
    @move_start_time = nil

    time_used
  end

  # Get current time for a color (accounting for active move)
  # @param color [Symbol] :white or :black
  # @return [Float] Remaining time in seconds
  def time_for(color)
    base_time = color == :white ? @white_time : @black_time

    # If this color is currently moving, subtract elapsed time
    if @active_color == color && @move_start_time
      elapsed = Time.now - @move_start_time
      base_time - elapsed
    else
      base_time
    end
  end

  # Check if a player has run out of time
  # @param color [Symbol] :white or :black
  # @return [Boolean] true if player has no time left
  def time_expired?(color)
    time_for(color) <= 0
  end

  # Format time as MM:SS or HH:MM:SS
  # @param seconds [Float] Time in seconds
  # @return [String] Formatted time string
  def self.format_time(seconds)
    return "0:00" if seconds <= 0

    total_seconds = seconds.to_i
    hours = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    secs = total_seconds % 60

    if hours > 0
      format("%d:%02d:%02d", hours, minutes, secs)
    else
      format("%d:%02d", minutes, secs)
    end
  end

  # Get formatted time for a color
  # @param color [Symbol] :white or :black
  # @return [String] Formatted time string
  def formatted_time(color)
    Clock.format_time(time_for(color))
  end

  # Check if clock is active (timing a move)
  # @return [Boolean] true if currently timing a move
  def active?
    !@active_color.nil?
  end

  # Get the color currently on the clock
  # @return [Symbol, nil] :white, :black, or nil if clock is stopped
  def active_color
    @active_color
  end
end
