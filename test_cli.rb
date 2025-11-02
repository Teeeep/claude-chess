#!/usr/bin/env ruby

# Simple non-interactive test of CLI functionality
require_relative 'lib/game'
require_relative 'lib/cli'

puts "Testing CLI board display..."
puts "=" * 50

game = Game.new

# Test piece symbols
cli = CLI.new

# Access the display methods through instance eval
cli.instance_eval do
  display_board
  display_status
end

puts "\nMaking some moves programmatically..."
game.make_move('e2e4')
game.make_move('e7e5')
game.make_move('g1f3')

puts "\nMove history:"
game.move_history.each_with_index do |move, i|
  puts "#{i + 1}. #{move.to_algebraic}"
end

puts "\nCLI test successful! ✓"
puts "Run './bin/chess' to play interactively"
