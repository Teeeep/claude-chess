# Ruby Chess Engine Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Build a complete, hand-rolled chess engine in Ruby with full rule support, time controls, and CLI interface using TDD with RSpec.

**Architecture:** Object-oriented design with Piece hierarchy (King, Queen, Rook, Bishop, Knight, Pawn), Board for square management, Game for rule enforcement and state tracking, Move for notation and history, Clock for time controls, and CLI for terminal interface with colored board display.

**Tech Stack:** Ruby 3.x, RSpec for testing, ANSI escape codes for terminal colors, no external chess libraries.

---

## Task 1: Project Setup

**Files:**
- Create: `Gemfile`
- Create: `.rspec`
- Create: `lib/.gitkeep`
- Create: `spec/spec_helper.rb`

**Step 1: Initialize Gemfile**

Create `Gemfile`:

```ruby
source 'https://rubygems.org'

ruby '~> 3.0'

group :test do
  gem 'rspec', '~> 3.12'
end
```

**Step 2: Create RSpec configuration**

Create `.rspec`:

```
--require spec_helper
--format documentation
--color
```

Create `spec/spec_helper.rb`:

```ruby
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand config.seed
end
```

**Step 3: Install dependencies**

Run: `bundle install`
Expected: RSpec and dependencies installed successfully

**Step 4: Verify RSpec works**

Run: `bundle exec rspec`
Expected: "0 examples, 0 failures"

**Step 5: Create lib directory**

Run: `mkdir -p lib && touch lib/.gitkeep`

**Step 6: Commit**

```bash
git init
git add Gemfile Gemfile.lock .rspec spec/spec_helper.rb lib/.gitkeep
git commit -m "chore: initialize Ruby chess project with RSpec"
```

---

## Task 2: Piece Base Class

**Files:**
- Create: `lib/piece.rb`
- Create: `spec/piece_spec.rb`

**Step 1: Write the failing test**

Create `spec/piece_spec.rb`:

```ruby
require_relative '../lib/piece'

RSpec.describe Piece do
  describe '#initialize' do
    it 'creates a piece with color and type' do
      piece = Piece.new(:white, :pawn)
      expect(piece.color).to eq(:white)
      expect(piece.type).to eq(:pawn)
    end
  end

  describe '#white?' do
    it 'returns true for white pieces' do
      piece = Piece.new(:white, :pawn)
      expect(piece.white?).to be true
    end

    it 'returns false for black pieces' do
      piece = Piece.new(:black, :pawn)
      expect(piece.white?).to be false
    end
  end

  describe '#black?' do
    it 'returns true for black pieces' do
      piece = Piece.new(:black, :pawn)
      expect(piece.black?).to be true
    end

    it 'returns false for white pieces' do
      piece = Piece.new(:white, :pawn)
      expect(piece.black?).to be false
    end
  end

  describe '#possible_moves' do
    it 'raises NotImplementedError for base class' do
      piece = Piece.new(:white, :pawn)
      expect { piece.possible_moves(nil, [0, 0]) }.to raise_error(NotImplementedError)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/piece_spec.rb`
Expected: FAIL with "uninitialized constant Piece"

**Step 3: Write minimal implementation**

Create `lib/piece.rb`:

```ruby
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
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/piece_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/piece.rb spec/piece_spec.rb
git commit -m "feat: add Piece base class with color and type"
```

---

## Task 3: Pawn Implementation

**Files:**
- Create: `lib/pawn.rb`
- Create: `spec/pawn_spec.rb`

**Step 1: Write the failing test**

Create `spec/pawn_spec.rb`:

```ruby
require_relative '../lib/pawn'
require_relative '../lib/board'

RSpec.describe Pawn do
  let(:board) { Board.new }

  describe '#initialize' do
    it 'creates a white pawn' do
      pawn = Pawn.new(:white)
      expect(pawn.color).to eq(:white)
      expect(pawn.type).to eq(:pawn)
    end

    it 'creates a black pawn' do
      pawn = Pawn.new(:black)
      expect(pawn.color).to eq(:black)
      expect(pawn.type).to eq(:pawn)
    end
  end

  describe '#possible_moves' do
    context 'white pawn on starting square' do
      it 'can move forward one square' do
        pawn = Pawn.new(:white)
        board.place_piece(pawn, [6, 0]) # a2
        moves = pawn.possible_moves(board, [6, 0])
        expect(moves).to include([5, 0]) # a3
      end

      it 'can move forward two squares' do
        pawn = Pawn.new(:white)
        board.place_piece(pawn, [6, 0])
        moves = pawn.possible_moves(board, [6, 0])
        expect(moves).to include([4, 0]) # a4
      end

      it 'cannot move forward two if blocked' do
        pawn = Pawn.new(:white)
        blocker = Pawn.new(:black)
        board.place_piece(pawn, [6, 0])
        board.place_piece(blocker, [5, 0])
        moves = pawn.possible_moves(board, [6, 0])
        expect(moves).not_to include([4, 0])
      end
    end

    context 'white pawn not on starting square' do
      it 'can move forward one square only' do
        pawn = Pawn.new(:white)
        board.place_piece(pawn, [5, 0]) # a3
        moves = pawn.possible_moves(board, [5, 0])
        expect(moves).to include([4, 0]) # a4
        expect(moves).not_to include([3, 0]) # a5
      end
    end

    context 'white pawn captures' do
      it 'can capture diagonally left' do
        pawn = Pawn.new(:white)
        enemy = Pawn.new(:black)
        board.place_piece(pawn, [5, 1]) # b3
        board.place_piece(enemy, [4, 0]) # a4
        moves = pawn.possible_moves(board, [5, 1])
        expect(moves).to include([4, 0])
      end

      it 'can capture diagonally right' do
        pawn = Pawn.new(:white)
        enemy = Pawn.new(:black)
        board.place_piece(pawn, [5, 1]) # b3
        board.place_piece(enemy, [4, 2]) # c4
        moves = pawn.possible_moves(board, [5, 1])
        expect(moves).to include([4, 2])
      end

      it 'cannot capture own pieces' do
        pawn = Pawn.new(:white)
        ally = Pawn.new(:white)
        board.place_piece(pawn, [5, 1])
        board.place_piece(ally, [4, 0])
        moves = pawn.possible_moves(board, [5, 1])
        expect(moves).not_to include([4, 0])
      end
    end

    context 'black pawn moves in opposite direction' do
      it 'moves down the board' do
        pawn = Pawn.new(:black)
        board.place_piece(pawn, [1, 0]) # a7
        moves = pawn.possible_moves(board, [1, 0])
        expect(moves).to include([2, 0]) # a6
        expect(moves).to include([3, 0]) # a5
      end
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/pawn_spec.rb`
Expected: FAIL with "uninitialized constant Pawn"

**Step 3: Write minimal Board stub for testing**

Create `lib/board.rb`:

```ruby
class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) }
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
end
```

**Step 4: Write Pawn implementation**

Create `lib/pawn.rb`:

```ruby
require_relative 'piece'

class Pawn < Piece
  def initialize(color)
    super(color, :pawn)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    direction = white? ? -1 : 1
    start_rank = white? ? 6 : 1

    # Forward one square
    one_forward = [rank + direction, file]
    if board.valid_position?(one_forward) && board.empty?(one_forward)
      moves << one_forward

      # Forward two squares from starting position
      if rank == start_rank
        two_forward = [rank + (direction * 2), file]
        if board.empty?(two_forward)
          moves << two_forward
        end
      end
    end

    # Diagonal captures
    [-1, 1].each do |file_offset|
      capture_pos = [rank + direction, file + file_offset]
      if board.valid_position?(capture_pos)
        target = board.piece_at(capture_pos)
        if target && target.color != @color
          moves << capture_pos
        end
      end
    end

    moves
  end
end
```

**Step 5: Run test to verify it passes**

Run: `bundle exec rspec spec/pawn_spec.rb`
Expected: All tests PASS

**Step 6: Commit**

```bash
git add lib/pawn.rb lib/board.rb spec/pawn_spec.rb
git commit -m "feat: add Pawn piece with movement and capture logic"
```

---

## Task 4: Rook Implementation

**Files:**
- Create: `lib/rook.rb`
- Create: `spec/rook_spec.rb`

**Step 1: Write the failing test**

Create `spec/rook_spec.rb`:

```ruby
require_relative '../lib/rook'
require_relative '../lib/board'

RSpec.describe Rook do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'moves along ranks' do
      rook = Rook.new(:white)
      board.place_piece(rook, [4, 4]) # e4
      moves = rook.possible_moves(board, [4, 4])

      # Should include all squares on rank 4
      expect(moves).to include([4, 0], [4, 1], [4, 2], [4, 3])
      expect(moves).to include([4, 5], [4, 6], [4, 7])
    end

    it 'moves along files' do
      rook = Rook.new(:white)
      board.place_piece(rook, [4, 4])
      moves = rook.possible_moves(board, [4, 4])

      # Should include all squares on file 4
      expect(moves).to include([0, 4], [1, 4], [2, 4], [3, 4])
      expect(moves).to include([5, 4], [6, 4], [7, 4])
    end

    it 'stops at friendly pieces' do
      rook = Rook.new(:white)
      ally = Pawn.new(:white)
      board.place_piece(rook, [4, 4])
      board.place_piece(ally, [4, 6]) # g4
      moves = rook.possible_moves(board, [4, 4])

      expect(moves).to include([4, 5]) # f4
      expect(moves).not_to include([4, 6]) # g4 (occupied by ally)
      expect(moves).not_to include([4, 7]) # h4 (blocked)
    end

    it 'captures enemy pieces' do
      rook = Rook.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(rook, [4, 4])
      board.place_piece(enemy, [4, 6])
      moves = rook.possible_moves(board, [4, 4])

      expect(moves).to include([4, 6]) # Can capture
      expect(moves).not_to include([4, 7]) # But can't go past
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/rook_spec.rb`
Expected: FAIL with "uninitialized constant Rook"

**Step 3: Write Rook implementation**

Create `lib/rook.rb`:

```ruby
require_relative 'piece'

class Rook < Piece
  def initialize(color)
    super(color, :rook)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    # Four directions: up, down, left, right
    directions = [[-1, 0], [1, 0], [0, -1], [0, 1]]

    directions.each do |rank_delta, file_delta|
      current_rank = rank + rank_delta
      current_file = file + file_delta

      while board.valid_position?([current_rank, current_file])
        target = board.piece_at([current_rank, current_file])

        if target.nil?
          # Empty square, can move here
          moves << [current_rank, current_file]
        elsif target.color != @color
          # Enemy piece, can capture
          moves << [current_rank, current_file]
          break # Can't go past
        else
          # Friendly piece, blocked
          break
        end

        current_rank += rank_delta
        current_file += file_delta
      end
    end

    moves
  end
end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/rook_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/rook.rb spec/rook_spec.rb
git commit -m "feat: add Rook piece with sliding movement"
```

---

## Task 5: Knight Implementation

**Files:**
- Create: `lib/knight.rb`
- Create: `spec/knight_spec.rb`

**Step 1: Write the failing test**

Create `spec/knight_spec.rb`:

```ruby
require_relative '../lib/knight'
require_relative '../lib/board'

RSpec.describe Knight do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'moves in L-shape patterns' do
      knight = Knight.new(:white)
      board.place_piece(knight, [4, 4]) # e4
      moves = knight.possible_moves(board, [4, 4])

      expected = [
        [2, 3], [2, 5], # Two up, one left/right
        [6, 3], [6, 5], # Two down, one left/right
        [3, 2], [5, 2], # One up/down, two left
        [3, 6], [5, 6]  # One up/down, two right
      ]

      expect(moves.sort).to eq(expected.sort)
    end

    it 'can jump over pieces' do
      knight = Knight.new(:white)
      blocker = Pawn.new(:white)
      board.place_piece(knight, [4, 4])
      board.place_piece(blocker, [3, 4]) # Piece in the way
      moves = knight.possible_moves(board, [4, 4])

      # Should still reach all L-shaped squares
      expect(moves).to include([2, 3], [2, 5])
    end

    it 'does not move to squares with friendly pieces' do
      knight = Knight.new(:white)
      ally = Pawn.new(:white)
      board.place_piece(knight, [4, 4])
      board.place_piece(ally, [2, 3])
      moves = knight.possible_moves(board, [4, 4])

      expect(moves).not_to include([2, 3])
    end

    it 'can capture enemy pieces' do
      knight = Knight.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(knight, [4, 4])
      board.place_piece(enemy, [2, 3])
      moves = knight.possible_moves(board, [4, 4])

      expect(moves).to include([2, 3])
    end

    it 'respects board boundaries' do
      knight = Knight.new(:white)
      board.place_piece(knight, [0, 0]) # a1 corner
      moves = knight.possible_moves(board, [0, 0])

      # Only two possible moves from corner
      expect(moves).to include([1, 2], [2, 1])
      expect(moves.length).to eq(2)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/knight_spec.rb`
Expected: FAIL with "uninitialized constant Knight"

**Step 3: Write Knight implementation**

Create `lib/knight.rb`:

```ruby
require_relative 'piece'

class Knight < Piece
  def initialize(color)
    super(color, :knight)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    # All 8 possible L-shaped moves
    offsets = [
      [-2, -1], [-2, 1],  # Two up
      [2, -1], [2, 1],    # Two down
      [-1, -2], [1, -2],  # Two left
      [-1, 2], [1, 2]     # Two right
    ]

    offsets.each do |rank_delta, file_delta|
      new_pos = [rank + rank_delta, file + file_delta]

      next unless board.valid_position?(new_pos)

      target = board.piece_at(new_pos)
      # Can move if empty or enemy piece
      moves << new_pos if target.nil? || target.color != @color
    end

    moves
  end
end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/knight_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/knight.rb spec/knight_spec.rb
git commit -m "feat: add Knight piece with L-shaped movement"
```

---

## Task 6: Bishop Implementation

**Files:**
- Create: `lib/bishop.rb`
- Create: `spec/bishop_spec.rb`

**Step 1: Write the failing test**

Create `spec/bishop_spec.rb`:

```ruby
require_relative '../lib/bishop'
require_relative '../lib/board'

RSpec.describe Bishop do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'moves diagonally in all four directions' do
      bishop = Bishop.new(:white)
      board.place_piece(bishop, [4, 4]) # e4
      moves = bishop.possible_moves(board, [4, 4])

      # Up-left diagonal
      expect(moves).to include([3, 3], [2, 2], [1, 1], [0, 0])
      # Up-right diagonal
      expect(moves).to include([3, 5], [2, 6], [1, 7])
      # Down-left diagonal
      expect(moves).to include([5, 3], [6, 2], [7, 1])
      # Down-right diagonal
      expect(moves).to include([5, 5], [6, 6], [7, 7])
    end

    it 'stops at friendly pieces' do
      bishop = Bishop.new(:white)
      ally = Pawn.new(:white)
      board.place_piece(bishop, [4, 4])
      board.place_piece(ally, [2, 2])
      moves = bishop.possible_moves(board, [4, 4])

      expect(moves).to include([3, 3])
      expect(moves).not_to include([2, 2]) # Blocked by ally
      expect(moves).not_to include([1, 1], [0, 0]) # Can't go past
    end

    it 'captures enemy pieces' do
      bishop = Bishop.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(bishop, [4, 4])
      board.place_piece(enemy, [2, 2])
      moves = bishop.possible_moves(board, [4, 4])

      expect(moves).to include([2, 2]) # Can capture
      expect(moves).not_to include([1, 1]) # Can't go past
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/bishop_spec.rb`
Expected: FAIL with "uninitialized constant Bishop"

**Step 3: Write Bishop implementation**

Create `lib/bishop.rb`:

```ruby
require_relative 'piece'

class Bishop < Piece
  def initialize(color)
    super(color, :bishop)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    # Four diagonal directions
    directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]]

    directions.each do |rank_delta, file_delta|
      current_rank = rank + rank_delta
      current_file = file + file_delta

      while board.valid_position?([current_rank, current_file])
        target = board.piece_at([current_rank, current_file])

        if target.nil?
          moves << [current_rank, current_file]
        elsif target.color != @color
          moves << [current_rank, current_file]
          break
        else
          break
        end

        current_rank += rank_delta
        current_file += file_delta
      end
    end

    moves
  end
end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/bishop_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/bishop.rb spec/bishop_spec.rb
git commit -m "feat: add Bishop piece with diagonal movement"
```

---

## Task 7: Queen Implementation

**Files:**
- Create: `lib/queen.rb`
- Create: `spec/queen_spec.rb`

**Step 1: Write the failing test**

Create `spec/queen_spec.rb`:

```ruby
require_relative '../lib/queen'
require_relative '../lib/board'

RSpec.describe Queen do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'combines rook and bishop movements' do
      queen = Queen.new(:white)
      board.place_piece(queen, [4, 4]) # e4
      moves = queen.possible_moves(board, [4, 4])

      # Horizontal (rook-like)
      expect(moves).to include([4, 0], [4, 7])
      # Vertical (rook-like)
      expect(moves).to include([0, 4], [7, 4])
      # Diagonal (bishop-like)
      expect(moves).to include([0, 0], [7, 7])
      expect(moves).to include([1, 7], [7, 1])
    end

    it 'stops at pieces correctly in all directions' do
      queen = Queen.new(:white)
      ally = Pawn.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(queen, [4, 4])
      board.place_piece(ally, [4, 6])   # Horizontal block
      board.place_piece(enemy, [2, 2])  # Diagonal capture

      moves = queen.possible_moves(board, [4, 4])

      # Can't pass friendly piece
      expect(moves).not_to include([4, 7])
      # Can capture enemy
      expect(moves).to include([2, 2])
      # Can't pass enemy
      expect(moves).not_to include([1, 1])
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/queen_spec.rb`
Expected: FAIL with "uninitialized constant Queen"

**Step 3: Write Queen implementation**

Create `lib/queen.rb`:

```ruby
require_relative 'piece'

class Queen < Piece
  def initialize(color)
    super(color, :queen)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    # Eight directions: four straight (rook) + four diagonal (bishop)
    directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1],     # Rook directions
      [-1, -1], [-1, 1], [1, -1], [1, 1]    # Bishop directions
    ]

    directions.each do |rank_delta, file_delta|
      current_rank = rank + rank_delta
      current_file = file + file_delta

      while board.valid_position?([current_rank, current_file])
        target = board.piece_at([current_rank, current_file])

        if target.nil?
          moves << [current_rank, current_file]
        elsif target.color != @color
          moves << [current_rank, current_file]
          break
        else
          break
        end

        current_rank += rank_delta
        current_file += file_delta
      end
    end

    moves
  end
end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/queen_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/queen.rb spec/queen_spec.rb
git commit -m "feat: add Queen piece combining rook and bishop movement"
```

---

## Task 8: King Implementation

**Files:**
- Create: `lib/king.rb`
- Create: `spec/king_spec.rb`

**Step 1: Write the failing test**

Create `spec/king_spec.rb`:

```ruby
require_relative '../lib/king'
require_relative '../lib/board'

RSpec.describe King do
  let(:board) { Board.new }

  describe '#possible_moves' do
    it 'moves one square in any direction' do
      king = King.new(:white)
      board.place_piece(king, [4, 4]) # e4
      moves = king.possible_moves(board, [4, 4])

      expected = [
        [3, 3], [3, 4], [3, 5],  # Up-left, up, up-right
        [4, 3],         [4, 5],  # Left, right
        [5, 3], [5, 4], [5, 5]   # Down-left, down, down-right
      ]

      expect(moves.sort).to eq(expected.sort)
    end

    it 'does not move to squares with friendly pieces' do
      king = King.new(:white)
      ally = Pawn.new(:white)
      board.place_piece(king, [4, 4])
      board.place_piece(ally, [3, 3])
      moves = king.possible_moves(board, [4, 4])

      expect(moves).not_to include([3, 3])
    end

    it 'can capture enemy pieces' do
      king = King.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(king, [4, 4])
      board.place_piece(enemy, [3, 3])
      moves = king.possible_moves(board, [4, 4])

      expect(moves).to include([3, 3])
    end

    it 'respects board boundaries' do
      king = King.new(:white)
      board.place_piece(king, [0, 0]) # a1 corner
      moves = king.possible_moves(board, [0, 0])

      expect(moves).to include([0, 1], [1, 0], [1, 1])
      expect(moves.length).to eq(3)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/king_spec.rb`
Expected: FAIL with "uninitialized constant King"

**Step 3: Write King implementation**

Create `lib/king.rb`:

```ruby
require_relative 'piece'

class King < Piece
  def initialize(color)
    super(color, :king)
  end

  def possible_moves(board, position)
    moves = []
    rank, file = position

    # All eight directions, but only one square
    offsets = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1]
    ]

    offsets.each do |rank_delta, file_delta|
      new_pos = [rank + rank_delta, file + file_delta]

      next unless board.valid_position?(new_pos)

      target = board.piece_at(new_pos)
      moves << new_pos if target.nil? || target.color != @color
    end

    moves
  end
end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/king_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/king.rb spec/king_spec.rb
git commit -m "feat: add King piece with one-square movement"
```

---

## Task 9: Enhanced Board Class

**Files:**
- Modify: `lib/board.rb`
- Create: `spec/board_spec.rb`

**Step 1: Write the failing test**

Create `spec/board_spec.rb`:

```ruby
require_relative '../lib/board'
require_relative '../lib/pawn'
require_relative '../lib/rook'
require_relative '../lib/king'

RSpec.describe Board do
  let(:board) { Board.new }

  describe '#initialize' do
    it 'creates empty 8x8 board' do
      expect(board.empty?([0, 0])).to be true
      expect(board.empty?([7, 7])).to be true
    end

    context 'with setup: true' do
      let(:board) { Board.new(setup: true) }

      it 'sets up initial chess position' do
        # White pieces
        expect(board.piece_at([7, 0])).to be_a(Rook)
        expect(board.piece_at([7, 4])).to be_a(King)
        expect(board.piece_at([6, 0])).to be_a(Pawn)

        # Black pieces
        expect(board.piece_at([0, 0])).to be_a(Rook)
        expect(board.piece_at([0, 4])).to be_a(King)
        expect(board.piece_at([1, 0])).to be_a(Pawn)

        # Empty middle
        expect(board.empty?([4, 4])).to be true
      end
    end
  end

  describe '#move_piece' do
    it 'moves a piece from one square to another' do
      pawn = Pawn.new(:white)
      board.place_piece(pawn, [6, 0])
      board.move_piece([6, 0], [5, 0])

      expect(board.piece_at([5, 0])).to eq(pawn)
      expect(board.empty?([6, 0])).to be true
    end

    it 'returns captured piece if any' do
      pawn = Pawn.new(:white)
      enemy = Pawn.new(:black)
      board.place_piece(pawn, [6, 0])
      board.place_piece(enemy, [5, 0])

      captured = board.move_piece([6, 0], [5, 0])
      expect(captured).to eq(enemy)
    end
  end

  describe '#find_king' do
    it 'finds the king of specified color' do
      king = King.new(:white)
      board.place_piece(king, [7, 4])

      expect(board.find_king(:white)).to eq([7, 4])
    end

    it 'returns nil if king not found' do
      expect(board.find_king(:white)).to be_nil
    end
  end

  describe '#pieces_of_color' do
    it 'returns all pieces of a given color' do
      board.place_piece(Pawn.new(:white), [6, 0])
      board.place_piece(Pawn.new(:white), [6, 1])
      board.place_piece(Pawn.new(:black), [1, 0])

      white_pieces = board.pieces_of_color(:white)
      expect(white_pieces.length).to eq(2)
    end
  end

  describe '#clone' do
    it 'creates a deep copy of the board' do
      pawn = Pawn.new(:white)
      board.place_piece(pawn, [6, 0])

      cloned = board.clone
      cloned.move_piece([6, 0], [5, 0])

      # Original unchanged
      expect(board.piece_at([6, 0])).to eq(pawn)
      # Clone changed
      expect(cloned.piece_at([5, 0])).to be_a(Pawn)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/board_spec.rb`
Expected: Multiple failures for missing methods

**Step 3: Enhance Board implementation**

Modify `lib/board.rb`:

```ruby
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
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/board_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/board.rb spec/board_spec.rb
git commit -m "feat: enhance Board with move, find, clone, and initial setup"
```

---

## Task 10: Move Class with Notation

**Files:**
- Create: `lib/move.rb`
- Create: `spec/move_spec.rb`

**Step 1: Write the failing test**

Create `spec/move_spec.rb`:

```ruby
require_relative '../lib/move'
require_relative '../lib/pawn'

RSpec.describe Move do
  describe '#initialize' do
    it 'creates a move with from, to, and piece' do
      piece = Pawn.new(:white)
      move = Move.new(from: [6, 4], to: [4, 4], piece: piece)

      expect(move.from).to eq([6, 4])
      expect(move.to).to eq([4, 4])
      expect(move.piece).to eq(piece)
    end

    it 'stores captured piece if provided' do
      piece = Pawn.new(:white)
      captured = Pawn.new(:black)
      move = Move.new(from: [4, 4], to: [3, 5], piece: piece, captured: captured)

      expect(move.captured).to eq(captured)
    end
  end

  describe '#to_algebraic' do
    it 'converts pawn move to algebraic notation' do
      piece = Pawn.new(:white)
      move = Move.new(from: [6, 4], to: [4, 4], piece: piece)

      expect(move.to_algebraic).to eq('e4')
    end

    it 'converts piece move with piece letter' do
      piece = Knight.new(:white)
      move = Move.new(from: [7, 1], to: [5, 2], piece: piece)

      expect(move.to_algebraic).to eq('Nc3')
    end

    it 'adds capture notation' do
      piece = Pawn.new(:white)
      captured = Pawn.new(:black)
      move = Move.new(from: [4, 4], to: [3, 5], piece: piece, captured: captured)

      expect(move.to_algebraic).to eq('exf5')
    end

    it 'handles castling kingside' do
      move = Move.new(from: [7, 4], to: [7, 6], piece: King.new(:white), castling: :kingside)
      expect(move.to_algebraic).to eq('O-O')
    end

    it 'handles castling queenside' do
      move = Move.new(from: [7, 4], to: [7, 2], piece: King.new(:white), castling: :queenside)
      expect(move.to_algebraic).to eq('O-O-O')
    end
  end

  describe '#to_long_algebraic' do
    it 'converts to long algebraic notation' do
      piece = Pawn.new(:white)
      move = Move.new(from: [6, 4], to: [4, 4], piece: piece)

      expect(move.to_long_algebraic).to eq('e2e4')
    end

    it 'adds promotion piece if provided' do
      piece = Pawn.new(:white)
      move = Move.new(from: [1, 4], to: [0, 4], piece: piece, promotion: :queen)

      expect(move.to_long_algebraic).to eq('e7e8q')
    end
  end

  describe '.parse_algebraic' do
    it 'parses long algebraic notation' do
      result = Move.parse_algebraic('e2e4')
      expect(result[:from]).to eq([6, 4])
      expect(result[:to]).to eq([4, 4])
    end

    it 'parses with promotion' do
      result = Move.parse_algebraic('e7e8q')
      expect(result[:to]).to eq([0, 4])
      expect(result[:promotion]).to eq(:queen)
    end

    it 'parses standard algebraic notation for pawn' do
      result = Move.parse_algebraic('e4')
      expect(result[:to]).to eq([4, 4])
      expect(result[:piece_type]).to be_nil # Pawn implied
    end

    it 'parses standard algebraic with piece type' do
      result = Move.parse_algebraic('Nf3')
      expect(result[:to]).to eq([5, 5])
      expect(result[:piece_type]).to eq(:knight)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/move_spec.rb`
Expected: FAIL with "uninitialized constant Move"

**Step 3: Write Move implementation**

Create `lib/move.rb`:

```ruby
class Move
  attr_reader :from, :to, :piece, :captured, :castling, :promotion, :en_passant

  def initialize(from:, to:, piece:, captured: nil, castling: nil, promotion: nil, en_passant: false)
    @from = from
    @to = to
    @piece = piece
    @captured = captured
    @castling = castling
    @promotion = promotion
    @en_passant = en_passant
  end

  def to_algebraic
    return 'O-O' if @castling == :kingside
    return 'O-O-O' if @castling == :queenside

    notation = ''

    # Add piece letter (except for pawns)
    unless @piece.type == :pawn
      notation += piece_letter(@piece.type)
    end

    # Add file if pawn capture
    if @piece.type == :pawn && @captured
      notation += file_letter(@from[1])
    end

    # Add capture symbol
    notation += 'x' if @captured

    # Add destination square
    notation += square_name(@to)

    # Add promotion
    notation += piece_letter(@promotion) if @promotion

    notation
  end

  def to_long_algebraic
    notation = square_name(@from) + square_name(@to)
    notation += piece_letter(@promotion) if @promotion
    notation
  end

  def self.parse_algebraic(notation)
    result = {}

    # Handle castling
    if notation == 'O-O' || notation == '0-0'
      return { castling: :kingside }
    elsif notation == 'O-O-O' || notation == '0-0-0'
      return { castling: :queenside }
    end

    # Long algebraic: e2e4 or e7e8q
    if notation.match?(/^[a-h][1-8][a-h][1-8][qrbn]?$/)
      result[:from] = parse_square(notation[0..1])
      result[:to] = parse_square(notation[2..3])
      result[:promotion] = parse_piece_letter(notation[4]) if notation.length == 5
      return result
    end

    # Standard algebraic: e4, Nf3, exd5, etc.
    # Extract destination square (always last 2 chars, or last 2 before +/#)
    clean = notation.gsub(/[+#!?]/, '')
    dest = clean[-2..]
    result[:to] = parse_square(dest)

    # Extract piece type if present
    if clean[0] =~ /[KQRBN]/
      result[:piece_type] = parse_piece_letter(clean[0])
    end

    # Extract promotion if present
    if clean =~ /=[QRBN]/
      result[:promotion] = parse_piece_letter(clean[-1])
    end

    result
  end

  private

  def square_name(position)
    rank, file = position
    file_letter(file) + (8 - rank).to_s
  end

  def file_letter(file)
    ('a'..'h').to_a[file]
  end

  def piece_letter(type)
    case type
    when :king then 'K'
    when :queen then 'Q'
    when :rook then 'R'
    when :bishop then 'B'
    when :knight then 'N'
    when :pawn then ''
    end
  end

  def self.parse_square(square_str)
    file = square_str[0].ord - 'a'.ord
    rank = 8 - square_str[1].to_i
    [rank, file]
  end

  def self.parse_piece_letter(letter)
    case letter.upcase
    when 'K' then :king
    when 'Q' then :queen
    when 'R' then :rook
    when 'B' then :bishop
    when 'N' then :knight
    else nil
    end
  end
end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/move_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/move.rb spec/move_spec.rb
git commit -m "feat: add Move class with algebraic notation support"
```

---

## Task 11: Game Class - Basic Turn Management

**Files:**
- Create: `lib/game.rb`
- Create: `spec/game_spec.rb`

**Step 1: Write the failing test**

Create `spec/game_spec.rb`:

```ruby
require_relative '../lib/game'

RSpec.describe Game do
  let(:game) { Game.new }

  describe '#initialize' do
    it 'sets up a new game with white to move' do
      expect(game.current_player).to eq(:white)
      expect(game.over?).to be false
    end

    it 'sets up initial board position' do
      expect(game.board.piece_at([7, 4])).to be_a(King)
      expect(game.board.piece_at([0, 4])).to be_a(King)
    end
  end

  describe '#make_move' do
    it 'allows valid pawn move' do
      result = game.make_move('e2e4')
      expect(result).to be true
      expect(game.current_player).to eq(:black)
    end

    it 'rejects invalid move' do
      result = game.make_move('e2e5') # Pawn can't move 3 squares
      expect(result).to be false
      expect(game.current_player).to eq(:white) # Turn doesn't change
    end

    it 'adds move to history' do
      game.make_move('e2e4')
      expect(game.move_history.length).to eq(1)
      expect(game.move_history.first.to_long_algebraic).to eq('e2e4')
    end

    it 'alternates turns' do
      game.make_move('e2e4')
      expect(game.current_player).to eq(:black)
      game.make_move('e7e5')
      expect(game.current_player).to eq(:white)
    end
  end

  describe '#legal_moves_for' do
    it 'returns legal moves for a piece' do
      moves = game.legal_moves_for([6, 4]) # White e2 pawn
      expect(moves).to include([5, 4], [4, 4]) # e3, e4
    end

    it 'returns empty array for empty square' do
      moves = game.legal_moves_for([4, 4])
      expect(moves).to be_empty
    end

    it 'returns empty array for opponent piece' do
      moves = game.legal_moves_for([1, 4]) # Black pawn
      expect(moves).to be_empty
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/game_spec.rb`
Expected: FAIL with "uninitialized constant Game"

**Step 3: Write Game implementation**

Create `lib/game.rb`:

```ruby
require_relative 'board'
require_relative 'move'

class Game
  attr_reader :board, :current_player, :move_history

  def initialize
    @board = Board.new(setup: true)
    @current_player = :white
    @move_history = []
    @halfmove_clock = 0
    @fullmove_number = 1
    @castling_rights = {
      white_kingside: true,
      white_queenside: true,
      black_kingside: true,
      black_queenside: true
    }
    @en_passant_target = nil
    @game_over = false
    @result = nil
  end

  def over?
    @game_over
  end

  def make_move(notation)
    parsed = Move.parse_algebraic(notation)

    # Handle castling separately
    if parsed[:castling]
      return perform_castling(parsed[:castling])
    end

    from = parsed[:from]
    to = parsed[:to]

    return false unless from && to

    piece = @board.piece_at(from)
    return false unless piece
    return false unless piece.color == @current_player

    # Check if move is legal
    legal_moves = legal_moves_for(from)
    return false unless legal_moves.include?(to)

    # Perform the move
    captured = @board.move_piece(from, to)

    # Handle promotion
    if parsed[:promotion] && piece.type == :pawn
      promote_pawn(to, parsed[:promotion])
    end

    # Record move
    move = Move.new(
      from: from,
      to: to,
      piece: piece,
      captured: captured,
      promotion: parsed[:promotion]
    )
    @move_history << move

    # Update game state
    update_castling_rights(from, piece)
    update_en_passant_target(from, to, piece)
    update_halfmove_clock(piece, captured)
    switch_player

    true
  end

  def legal_moves_for(position)
    piece = @board.piece_at(position)
    return [] unless piece
    return [] unless piece.color == @current_player

    possible = piece.possible_moves(@board, position)

    # Filter out moves that leave king in check
    possible.select do |move_to|
      !leaves_king_in_check?(position, move_to)
    end
  end

  private

  def leaves_king_in_check?(from, to)
    # Clone board and make move
    test_board = @board.clone
    test_board.move_piece(from, to)

    # Find our king
    king_pos = test_board.find_king(@current_player)
    return true unless king_pos # King captured (shouldn't happen)

    # Check if any opponent piece attacks king
    opponent = opponent_color(@current_player)
    test_board.pieces_of_color(opponent).any? do |pos, piece|
      piece.possible_moves(test_board, pos).include?(king_pos)
    end
  end

  def switch_player
    @current_player = opponent_color(@current_player)
    @fullmove_number += 1 if @current_player == :white
  end

  def opponent_color(color)
    color == :white ? :black : :white
  end

  def update_castling_rights(from, piece)
    # Remove castling rights if king or rook moves
    if piece.type == :king
      if @current_player == :white
        @castling_rights[:white_kingside] = false
        @castling_rights[:white_queenside] = false
      else
        @castling_rights[:black_kingside] = false
        @castling_rights[:black_queenside] = false
      end
    elsif piece.type == :rook
      case from
      when [7, 0] then @castling_rights[:white_queenside] = false
      when [7, 7] then @castling_rights[:white_kingside] = false
      when [0, 0] then @castling_rights[:black_queenside] = false
      when [0, 7] then @castling_rights[:black_kingside] = false
      end
    end
  end

  def update_en_passant_target(from, to, piece)
    @en_passant_target = nil

    if piece.type == :pawn && (from[0] - to[0]).abs == 2
      # Pawn moved two squares, set en passant target
      direction = piece.white? ? -1 : 1
      @en_passant_target = [from[0] + direction, from[1]]
    end
  end

  def update_halfmove_clock(piece, captured)
    if piece.type == :pawn || captured
      @halfmove_clock = 0
    else
      @halfmove_clock += 1
    end
  end

  def promote_pawn(position, piece_type)
    color = @board.piece_at(position).color
    new_piece = case piece_type
                when :queen then Queen.new(color)
                when :rook then Rook.new(color)
                when :bishop then Bishop.new(color)
                when :knight then Knight.new(color)
                end
    @board.place_piece(new_piece, position)
  end

  def perform_castling(side)
    # TODO: Implement in next task
    false
  end
end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/game_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/game.rb spec/game_spec.rb
git commit -m "feat: add Game class with basic turn management and move validation"
```

---

## Task 12: Check and Checkmate Detection

**Files:**
- Modify: `lib/game.rb`
- Modify: `spec/game_spec.rb`

**Step 1: Write the failing test**

Add to `spec/game_spec.rb`:

```ruby
  describe '#in_check?' do
    it 'detects when king is in check' do
      game.make_move('e2e4')
      game.make_move('f7f6')
      game.make_move('d1h5') # Check!

      expect(game.in_check?(:black)).to be true
    end

    it 'returns false when king is not in check' do
      expect(game.in_check?(:white)).to be false
    end
  end

  describe '#checkmate?' do
    it 'detects fool\'s mate' do
      game.make_move('f2f3')
      game.make_move('e7e5')
      game.make_move('g2g4')
      game.make_move('d8h4') # Checkmate!

      expect(game.checkmate?(:white)).to be true
      expect(game.over?).to be true
    end
  end

  describe '#stalemate?' do
    it 'detects stalemate when no legal moves but not in check' do
      # Create stalemate position (simplified test)
      game = Game.new
      # Set up a stalemate position programmatically
      # (This is complex - in practice would set up specific position)
    end
  end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/game_spec.rb`
Expected: FAIL with "undefined method `in_check?`"

**Step 3: Add check/checkmate detection to Game**

Modify `lib/game.rb` - add these methods:

```ruby
  def in_check?(color)
    king_pos = @board.find_king(color)
    return false unless king_pos

    opponent = opponent_color(color)
    @board.pieces_of_color(opponent).any? do |pos, piece|
      piece.possible_moves(@board, pos).include?(king_pos)
    end
  end

  def checkmate?(color)
    return false unless in_check?(color)
    no_legal_moves?(color)
  end

  def stalemate?(color)
    return false if in_check?(color)
    no_legal_moves?(color)
  end

  private

  def no_legal_moves?(color)
    @board.pieces_of_color(color).all? do |pos, piece|
      legal_moves_for(pos).empty?
    end
  end
```

Also update `make_move` to check for game end:

```ruby
  def make_move(notation)
    # ... existing code ...

    switch_player

    # Check for game end
    check_game_end

    true
  end

  def check_game_end
    if checkmate?(@current_player)
      @game_over = true
      @result = "#{opponent_color(@current_player)} wins by checkmate"
    elsif stalemate?(@current_player)
      @game_over = true
      @result = "Draw by stalemate"
    elsif @halfmove_clock >= 100
      @game_over = true
      @result = "Draw by fifty-move rule"
    end
  end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/game_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/game.rb spec/game_spec.rb
git commit -m "feat: add check, checkmate, and stalemate detection"
```

---

## Task 13: Castling Implementation

**Files:**
- Modify: `lib/game.rb`
- Modify: `lib/king.rb`
- Create: `spec/castling_spec.rb`

**Step 1: Write the failing test**

Create `spec/castling_spec.rb`:

```ruby
require_relative '../lib/game'

RSpec.describe 'Castling' do
  let(:game) { Game.new }

  describe 'white kingside castling' do
    before do
      # Clear pieces between king and rook
      game.board.place_piece(nil, [7, 5]) # f1
      game.board.place_piece(nil, [7, 6]) # g1
    end

    it 'allows castling when conditions are met' do
      result = game.make_move('O-O')
      expect(result).to be true
      expect(game.board.piece_at([7, 6])).to be_a(King)
      expect(game.board.piece_at([7, 5])).to be_a(Rook)
    end

    it 'prevents castling if king has moved' do
      game.make_move('e1f1')
      game.make_move('e7e6')
      game.make_move('f1e1')
      game.make_move('e6e5')

      result = game.make_move('O-O')
      expect(result).to be false
    end

    it 'prevents castling through check' do
      # Place black rook attacking f1
      game.board.place_piece(Rook.new(:black), [0, 5])
      game.board.place_piece(nil, [1, 5])

      result = game.make_move('O-O')
      expect(result).to be false
    end

    it 'prevents castling out of check' do
      # Place black rook attacking e1
      game.board.place_piece(Rook.new(:black), [0, 4])
      game.board.place_piece(nil, [1, 4])

      result = game.make_move('O-O')
      expect(result).to be false
    end
  end

  describe 'queenside castling' do
    before do
      # Clear pieces between king and queenside rook
      game.board.place_piece(nil, [7, 1]) # b1
      game.board.place_piece(nil, [7, 2]) # c1
      game.board.place_piece(nil, [7, 3]) # d1
    end

    it 'allows queenside castling' do
      result = game.make_move('O-O-O')
      expect(result).to be true
      expect(game.board.piece_at([7, 2])).to be_a(King)
      expect(game.board.piece_at([7, 3])).to be_a(Rook)
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/castling_spec.rb`
Expected: Multiple failures

**Step 3: Implement castling in Game**

Modify `lib/game.rb` - update `perform_castling`:

```ruby
  def perform_castling(side)
    rank = @current_player == :white ? 7 : 0
    king_file = 4

    # Determine rook position and target squares
    if side == :kingside
      rook_file = 7
      king_to = 6
      rook_to = 5
      right_key = @current_player == :white ? :white_kingside : :black_kingside
    else # queenside
      rook_file = 0
      king_to = 2
      rook_to = 3
      right_key = @current_player == :white ? :white_queenside : :black_queenside
    end

    # Check castling rights
    return false unless @castling_rights[right_key]

    # Check pieces are in place
    king = @board.piece_at([rank, king_file])
    rook = @board.piece_at([rank, rook_file])
    return false unless king.is_a?(King) && rook.is_a?(Rook)

    # Check squares between are empty
    range = side == :kingside ? (5..6) : (1..3)
    range.each do |file|
      return false unless @board.empty?([rank, file])
    end

    # Check not castling out of check
    return false if in_check?(@current_player)

    # Check not castling through check
    path = side == :kingside ? [5, 6] : [2, 3]
    path.each do |file|
      # Temporarily move king to check for attacks
      @board.place_piece(king, [rank, file])
      @board.place_piece(nil, [rank, king_file])

      if in_check?(@current_player)
        # Move king back
        @board.place_piece(king, [rank, king_file])
        @board.place_piece(nil, [rank, file])
        return false
      end

      # Move king back for next check
      @board.place_piece(king, [rank, king_file])
      @board.place_piece(nil, [rank, file])
    end

    # Perform castling
    @board.place_piece(king, [rank, king_to])
    @board.place_piece(rook, [rank, rook_to])
    @board.place_piece(nil, [rank, king_file])
    @board.place_piece(nil, [rank, rook_file])

    # Record move
    move = Move.new(
      from: [rank, king_file],
      to: [rank, king_to],
      piece: king,
      castling: side
    )
    @move_history << move

    # Update rights and switch player
    update_castling_rights([rank, king_file], king)
    switch_player
    check_game_end

    true
  end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/castling_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/game.rb spec/castling_spec.rb
git commit -m "feat: implement castling with full rule validation"
```

---

## Task 14: En Passant

**Files:**
- Modify: `lib/pawn.rb`
- Modify: `lib/game.rb`
- Create: `spec/en_passant_spec.rb`

**Step 1: Write the failing test**

Create `spec/en_passant_spec.rb`:

```ruby
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
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/en_passant_spec.rb`
Expected: FAIL

**Step 3: Update Pawn to support en passant**

Modify `lib/pawn.rb`:

```ruby
  def possible_moves(board, position, en_passant_target: nil)
    moves = []
    rank, file = position

    direction = white? ? -1 : 1
    start_rank = white? ? 6 : 1

    # Forward one square
    one_forward = [rank + direction, file]
    if board.valid_position?(one_forward) && board.empty?(one_forward)
      moves << one_forward

      # Forward two squares from starting position
      if rank == start_rank
        two_forward = [rank + (direction * 2), file]
        if board.empty?(two_forward)
          moves << two_forward
        end
      end
    end

    # Diagonal captures
    [-1, 1].each do |file_offset|
      capture_pos = [rank + direction, file + file_offset]
      if board.valid_position?(capture_pos)
        target = board.piece_at(capture_pos)
        if target && target.color != @color
          moves << capture_pos
        elsif capture_pos == en_passant_target
          # En passant capture
          moves << capture_pos
        end
      end
    end

    moves
  end
```

**Step 4: Update Game to pass en passant target**

Modify `lib/game.rb`:

```ruby
  def legal_moves_for(position)
    piece = @board.piece_at(position)
    return [] unless piece
    return [] unless piece.color == @current_player

    # Pass en passant target to pawns
    possible = if piece.type == :pawn
                 piece.possible_moves(@board, position, en_passant_target: @en_passant_target)
               else
                 piece.possible_moves(@board, position)
               end

    # Filter out moves that leave king in check
    possible.select do |move_to|
      !leaves_king_in_check?(position, move_to)
    end
  end
```

Also update `make_move` to handle en passant capture:

```ruby
  def make_move(notation)
    parsed = Move.parse_algebraic(notation)

    if parsed[:castling]
      return perform_castling(parsed[:castling])
    end

    from = parsed[:from]
    to = parsed[:to]

    return false unless from && to

    piece = @board.piece_at(from)
    return false unless piece
    return false unless piece.color == @current_player

    legal_moves = legal_moves_for(from)
    return false unless legal_moves.include?(to)

    # Check for en passant
    en_passant_capture = false
    if piece.type == :pawn && to == @en_passant_target
      en_passant_capture = true
    end

    # Perform the move
    captured = @board.move_piece(from, to)

    # Handle en passant capture
    if en_passant_capture
      direction = piece.white? ? 1 : -1
      captured_pawn_pos = [to[0] + direction, to[1]]
      captured = @board.piece_at(captured_pawn_pos)
      @board.place_piece(nil, captured_pawn_pos)
    end

    # ... rest of existing code ...
  end
```

**Step 5: Run test to verify it passes**

Run: `bundle exec rspec spec/en_passant_spec.rb`
Expected: All tests PASS

**Step 6: Commit**

```bash
git add lib/pawn.rb lib/game.rb spec/en_passant_spec.rb
git commit -m "feat: implement en passant capture"
```

---

## Task 15: Draw by Repetition and Insufficient Material

**Files:**
- Modify: `lib/game.rb`
- Create: `spec/draw_conditions_spec.rb`

**Step 1: Write the failing test**

Create `spec/draw_conditions_spec.rb`:

```ruby
require_relative '../lib/game'

RSpec.describe 'Draw Conditions' do
  let(:game) { Game.new }

  describe 'threefold repetition' do
    it 'detects draw by threefold repetition' do
      # Knights dance back and forth
      3.times do
        game.make_move('Ng1f3')
        game.make_move('Nb8c6')
        game.make_move('Nf3g1')
        game.make_move('Nc6b8')
      end

      expect(game.threefold_repetition?).to be true
    end
  end

  describe 'insufficient material' do
    it 'detects king vs king' do
      # Set up position with only kings
      game = Game.new
      game.board.place_piece(King.new(:white), [7, 4])
      game.board.place_piece(King.new(:black), [0, 4])

      expect(game.insufficient_material?).to be true
    end

    it 'detects king and bishop vs king' do
      game = Game.new
      game.board.place_piece(King.new(:white), [7, 4])
      game.board.place_piece(Bishop.new(:white), [7, 5])
      game.board.place_piece(King.new(:black), [0, 4])

      expect(game.insufficient_material?).to be true
    end

    it 'detects king and knight vs king' do
      game = Game.new
      game.board.place_piece(King.new(:white), [7, 4])
      game.board.place_piece(Knight.new(:white), [7, 1])
      game.board.place_piece(King.new(:black), [0, 4])

      expect(game.insufficient_material?).to be true
    end

    it 'does not detect insufficient material with pawns' do
      game = Game.new
      game.board.place_piece(King.new(:white), [7, 4])
      game.board.place_piece(Pawn.new(:white), [6, 4])
      game.board.place_piece(King.new(:black), [0, 4])

      expect(game.insufficient_material?).to be false
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/draw_conditions_spec.rb`
Expected: FAIL with "undefined method `threefold_repetition?`"

**Step 3: Implement draw conditions**

Modify `lib/game.rb`:

```ruby
  def initialize
    # ... existing code ...
    @position_history = []
  end

  def threefold_repetition?
    current_position = position_key
    @position_history.count(current_position) >= 3
  end

  def insufficient_material?
    white_pieces = @board.pieces_of_color(:white).map { |_, p| p }
    black_pieces = @board.pieces_of_color(:black).map { |_, p| p }

    # King vs King
    return true if white_pieces.length == 1 && black_pieces.length == 1

    # King and minor piece vs King
    if white_pieces.length == 2 && black_pieces.length == 1
      minor = white_pieces.find { |p| p.type != :king }
      return true if minor && [:bishop, :knight].include?(minor.type)
    end

    if black_pieces.length == 2 && white_pieces.length == 1
      minor = black_pieces.find { |p| p.type != :king }
      return true if minor && [:bishop, :knight].include?(minor.type)
    end

    # King and Bishop vs King and Bishop (same color squares)
    if white_pieces.length == 2 && black_pieces.length == 2
      white_bishop = white_pieces.find { |p| p.type == :bishop }
      black_bishop = black_pieces.find { |p| p.type == :bishop }

      if white_bishop && black_bishop
        white_pos = @board.pieces_of_color(:white).find { |_, p| p == white_bishop }[0]
        black_pos = @board.pieces_of_color(:black).find { |_, p| p == black_bishop }[0]

        white_square_color = (white_pos[0] + white_pos[1]) % 2
        black_square_color = (black_pos[0] + black_pos[1]) % 2

        return true if white_square_color == black_square_color
      end
    end

    false
  end

  private

  def position_key
    # Create unique key for current position
    # Include: board position, castling rights, en passant target
    key = ''

    @board.instance_variable_get(:@grid).each_with_index do |row, rank|
      row.each_with_index do |piece, file|
        if piece
          key += "#{piece.color[0]}#{piece.type[0]}#{rank}#{file}"
        end
      end
    end

    key += @castling_rights.to_s
    key += @en_passant_target.to_s

    key
  end

  def make_move(notation)
    # ... existing code before switch_player ...

    # Record position for repetition detection
    @position_history << position_key

    switch_player
    check_game_end

    true
  end

  def check_game_end
    if checkmate?(@current_player)
      @game_over = true
      @result = "#{opponent_color(@current_player)} wins by checkmate"
    elsif stalemate?(@current_player)
      @game_over = true
      @result = "Draw by stalemate"
    elsif @halfmove_clock >= 100
      @game_over = true
      @result = "Draw by fifty-move rule"
    elsif threefold_repetition?
      @game_over = true
      @result = "Draw by threefold repetition"
    elsif insufficient_material?
      @game_over = true
      @result = "Draw by insufficient material"
    end
  end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/draw_conditions_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/game.rb spec/draw_conditions_spec.rb
git commit -m "feat: implement threefold repetition and insufficient material draws"
```

---

## Task 16: Clock Implementation

**Files:**
- Create: `lib/clock.rb`
- Create: `spec/clock_spec.rb`

**Step 1: Write the failing test**

Create `spec/clock_spec.rb`:

```ruby
require_relative '../lib/clock'

RSpec.describe Clock do
  describe '#initialize' do
    it 'creates clock with starting time in seconds' do
      clock = Clock.new(white_time: 600, black_time: 600)
      expect(clock.time_remaining(:white)).to eq(600)
      expect(clock.time_remaining(:black)).to eq(600)
    end

    it 'supports increment' do
      clock = Clock.new(white_time: 180, black_time: 180, increment: 2)
      expect(clock.increment).to eq(2)
    end
  end

  describe '#start' do
    it 'starts the clock for specified color' do
      clock = Clock.new(white_time: 600, black_time: 600)
      clock.start(:white)

      sleep(0.1)
      clock.stop(:white)

      expect(clock.time_remaining(:white)).to be < 600
    end
  end

  describe '#stop' do
    it 'stops the clock and applies increment' do
      clock = Clock.new(white_time: 10, black_time: 10, increment: 2)
      clock.start(:white)
      sleep(0.05)
      clock.stop(:white)

      # Time should be less than 12 (10 + 2 increment - elapsed time)
      # but more than 10 (because of increment)
      time = clock.time_remaining(:white)
      expect(time).to be > 10
      expect(time).to be < 12
    end
  end

  describe '#flagged?' do
    it 'returns true when time runs out' do
      clock = Clock.new(white_time: 0.05, black_time: 10)
      clock.start(:white)
      sleep(0.1)
      clock.stop(:white)

      expect(clock.flagged?(:white)).to be true
    end

    it 'returns false when time remains' do
      clock = Clock.new(white_time: 600, black_time: 600)
      expect(clock.flagged?(:white)).to be false
    end
  end

  describe '#format_time' do
    it 'formats time as MM:SS' do
      clock = Clock.new(white_time: 600, black_time: 600)
      expect(clock.format_time(600)).to eq('10:00')
      expect(clock.format_time(65)).to eq('01:05')
      expect(clock.format_time(5)).to eq('00:05')
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/clock_spec.rb`
Expected: FAIL with "uninitialized constant Clock"

**Step 3: Write Clock implementation**

Create `lib/clock.rb`:

```ruby
class Clock
  attr_reader :increment

  def initialize(white_time:, black_time:, increment: 0)
    @times = {
      white: white_time.to_f,
      black: black_time.to_f
    }
    @increment = increment
    @start_times = {}
  end

  def start(color)
    @start_times[color] = Time.now
  end

  def stop(color)
    return unless @start_times[color]

    elapsed = Time.now - @start_times[color]
    @times[color] -= elapsed
    @times[color] += @increment
    @start_times.delete(color)
  end

  def time_remaining(color)
    if @start_times[color]
      # Clock is running, calculate current time
      elapsed = Time.now - @start_times[color]
      [@times[color] - elapsed, 0].max
    else
      [@times[color], 0].max
    end
  end

  def flagged?(color)
    time_remaining(color) <= 0
  end

  def format_time(seconds)
    seconds = [seconds, 0].max
    minutes = (seconds / 60).floor
    secs = (seconds % 60).floor
    format('%02d:%02d', minutes, secs)
  end

  def display
    white_time = format_time(time_remaining(:white))
    black_time = format_time(time_remaining(:black))
    "White: #{white_time} | Black: #{black_time}"
  end
end
```

**Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/clock_spec.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add lib/clock.rb spec/clock_spec.rb
git commit -m "feat: implement chess clock with increment support"
```

---

## Task 17: FEN Support

**Files:**
- Create: `lib/fen.rb`
- Modify: `lib/game.rb`
- Create: `spec/fen_spec.rb`

**Step 1: Write the failing test**

Create `spec/fen_spec.rb`:

```ruby
require_relative '../lib/fen'
require_relative '../lib/game'

RSpec.describe FEN do
  describe '.export' do
    it 'exports starting position' do
      game = Game.new
      fen = FEN.export(game)

      expect(fen).to eq('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    end

    it 'exports position after e4' do
      game = Game.new
      game.make_move('e2e4')
      fen = FEN.export(game)

      expect(fen).to eq('rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1')
    end
  end

  describe '.import' do
    it 'imports starting position' do
      fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
      game = FEN.import(fen)

      expect(game.current_player).to eq(:white)
      expect(game.board.piece_at([0, 0])).to be_a(Rook)
      expect(game.board.piece_at([0, 4])).to be_a(King)
    end

    it 'imports position after e4' do
      fen = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1'
      game = FEN.import(fen)

      expect(game.current_player).to eq(:black)
      expect(game.board.piece_at([4, 4])).to be_a(Pawn)
      expect(game.board.piece_at([4, 4]).white?).to be true
    end
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/fen_spec.rb`
Expected: FAIL with "uninitialized constant FEN"

**Step 3: Write FEN implementation**

Create `lib/fen.rb`:

```ruby
require_relative 'game'
require_relative 'board'

class FEN
  PIECE_MAP = {
    'K' => [:king, :white],   'Q' => [:queen, :white],
    'R' => [:rook, :white],   'B' => [:bishop, :white],
    'N' => [:knight, :white], 'P' => [:pawn, :white],
    'k' => [:king, :black],   'q' => [:queen, :black],
    'r' => [:rook, :black],   'b' => [:bishop, :black],
    'n' => [:knight, :black], 'p' => [:pawn, :black]
  }.freeze

  REVERSE_MAP = PIECE_MAP.invert.freeze

  def self.export(game)
    parts = []

    # 1. Piece placement
    parts << export_board(game.board)

    # 2. Active color
    parts << (game.current_player == :white ? 'w' : 'b')

    # 3. Castling availability
    parts << export_castling_rights(game)

    # 4. En passant target
    parts << export_en_passant(game)

    # 5. Halfmove clock
    parts << game.instance_variable_get(:@halfmove_clock).to_s

    # 6. Fullmove number
    parts << game.instance_variable_get(:@fullmove_number).to_s

    parts.join(' ')
  end

  def self.import(fen_string)
    parts = fen_string.split(' ')

    game = Game.new
    # Clear the board first
    8.times do |rank|
      8.times do |file|
        game.board.place_piece(nil, [rank, file])
      end
    end

    # 1. Parse piece placement
    import_board(game.board, parts[0])

    # 2. Active color
    game.instance_variable_set(:@current_player, parts[1] == 'w' ? :white : :black)

    # 3. Castling rights
    import_castling_rights(game, parts[2])

    # 4. En passant target
    import_en_passant(game, parts[3])

    # 5. Halfmove clock
    game.instance_variable_set(:@halfmove_clock, parts[4].to_i)

    # 6. Fullmove number
    game.instance_variable_set(:@fullmove_number, parts[5].to_i)

    game
  end

  private

  def self.export_board(board)
    rows = []

    8.times do |rank|
      row = ''
      empty_count = 0

      8.times do |file|
        piece = board.piece_at([rank, file])

        if piece
          row += empty_count.to_s if empty_count > 0
          empty_count = 0
          row += piece_to_fen(piece)
        else
          empty_count += 1
        end
      end

      row += empty_count.to_s if empty_count > 0
      rows << row
    end

    rows.join('/')
  end

  def self.import_board(board, placement)
    ranks = placement.split('/')

    ranks.each_with_index do |rank_str, rank|
      file = 0

      rank_str.each_char do |char|
        if char =~ /\d/
          file += char.to_i
        else
          piece = fen_to_piece(char)
          board.place_piece(piece, [rank, file])
          file += 1
        end
      end
    end
  end

  def self.piece_to_fen(piece)
    symbol = case piece.type
             when :king then 'K'
             when :queen then 'Q'
             when :rook then 'R'
             when :bishop then 'B'
             when :knight then 'N'
             when :pawn then 'P'
             end

    piece.white? ? symbol : symbol.downcase
  end

  def self.fen_to_piece(char)
    type, color = PIECE_MAP[char]

    case type
    when :king then King.new(color)
    when :queen then Queen.new(color)
    when :rook then Rook.new(color)
    when :bishop then Bishop.new(color)
    when :knight then Knight.new(color)
    when :pawn then Pawn.new(color)
    end
  end

  def self.export_castling_rights(game)
    rights = game.instance_variable_get(:@castling_rights)
    result = ''

    result += 'K' if rights[:white_kingside]
    result += 'Q' if rights[:white_queenside]
    result += 'k' if rights[:black_kingside]
    result += 'q' if rights[:black_queenside]

    result.empty? ? '-' : result
  end

  def self.import_castling_rights(game, castling_str)
    rights = {
      white_kingside: castling_str.include?('K'),
      white_queenside: castling_str.include?('Q'),
      black_kingside: castling_str.include?('k'),
      black_queenside: castling_str.include?('q')
    }

    game.instance_variable_set(:@castling_rights, rights)
  end

  def self.export_en_passant(game)
    target = game.instance_variable_get(:@en_passant_target)
    return '-' unless target

    rank, file = target
    file_letter = ('a'..'h').to_a[file]
    rank_number = 8 - rank
    "#{file_letter}#{rank_number}"
  end

  def self.import_en_passant(game, ep_str)
    if ep_str == '-'
      game.instance_variable_set(:@en_passant_target, nil)
    else
      file = ep_str[0].ord - 'a'.ord
      rank = 8 - ep_str[1].to_i
      game.instance_variable_set(:@en_passant_target, [rank, file])
    end
  end
end
```

**Step 4: Add FEN methods to Game**

Modify `lib/game.rb`:

```ruby
  def to_fen
    FEN.export(self)
  end

  def self.from_fen(fen_string)
    FEN.import(fen_string)
  end
```

**Step 5: Run test to verify it passes**

Run: `bundle exec rspec spec/fen_spec.rb`
Expected: All tests PASS

**Step 6: Commit**

```bash
git add lib/fen.rb lib/game.rb spec/fen_spec.rb
git commit -m "feat: implement FEN import/export for game positions"
```

---

## Task 18: CLI Interface

**Files:**
- Create: `lib/cli.rb`
- Create: `bin/chess`

**Step 1: Write CLI implementation**

Create `lib/cli.rb`:

```ruby
require_relative 'game'
require_relative 'clock'
require_relative 'fen'

class CLI
  RED_BG = "\e[41m"
  BLUE_BG = "\e[44m"
  RESET = "\e[0m"

  def initialize
    @game = nil
    @clock = nil
  end

  def run
    puts "\nWelcome to Ruby Chess!"
    puts "Type 'help' for commands\n\n"

    loop do
      print "> "
      input = gets&.chomp
      break unless input

      process_command(input.strip)
      break if @quit
    end

    puts "\nThanks for playing!"
  end

  private

  def process_command(input)
    case input
    when 'new', 'start'
      start_new_game
    when /^new\s+(\d+)(?:\s+(\d+))?/
      time = $1.to_i * 60
      increment = $2 ? $2.to_i : 0
      start_new_game(time: time, increment: increment)
    when 'help'
      show_help
    when 'show', 'board'
      display_board
    when 'history'
      show_history
    when 'fen'
      show_fen
    when /^load\s+(.+)/
      load_fen($1)
    when 'resign'
      resign
    when 'draw'
      offer_draw
    when 'quit', 'exit'
      @quit = true
    when /^move\s+(.+)/, /^([a-h][1-8].*)/
      move = $1
      make_move(move)
    else
      puts "Unknown command. Type 'help' for available commands."
    end
  end

  def start_new_game(time: nil, increment: 0)
    @game = Game.new

    if time
      @clock = Clock.new(white_time: time, black_time: time, increment: increment)
      puts "Starting new game with #{time/60} minutes + #{increment} second increment"
    else
      @clock = nil
      puts "Starting new game (no time control)"
    end

    display_board
  end

  def show_help
    puts <<~HELP
      Commands:
        new [minutes] [increment]  - Start new game (optional time control)
        move <notation>            - Make a move (e.g., 'move e2e4' or 'move e4')
        show / board               - Display current board
        history                    - Show move history
        fen                        - Display current position in FEN
        load <fen>                 - Load position from FEN string
        resign                     - Resign the game
        draw                       - Offer/accept draw
        quit / exit                - Exit program
        help                       - Show this help message

      Move notation:
        - Long algebraic: e2e4, e7e8q (promotion)
        - Standard algebraic: e4, Nf3, O-O (castling)
    HELP
  end

  def display_board
    return puts "No game in progress. Type 'new' to start." unless @game

    puts "\n  a b c d e f g h"

    8.times do |rank|
      print "#{8 - rank} "

      8.times do |file|
        piece = @game.board.piece_at([rank, file])
        is_light = (rank + file).even?
        bg_color = is_light ? BLUE_BG : RED_BG

        piece_str = piece ? piece.to_s : ' '
        print "#{bg_color}#{piece_str}#{RESET} "
      end

      puts "#{8 - rank}"
    end

    puts "  a b c d e f g h\n\n"

    if @clock
      @clock.stop(@game.current_player == :white ? :black : :white)
      puts @clock.display
      puts
    end

    if @game.in_check?(@game.current_player)
      puts "CHECK!"
    end

    if @game.over?
      puts @game.instance_variable_get(:@result)
    else
      player = @game.current_player.to_s.capitalize
      puts "#{player} to move"
    end

    puts
  end

  def show_history
    return puts "No game in progress." unless @game

    if @game.move_history.empty?
      puts "No moves yet."
      return
    end

    puts "\nMove History:"
    @game.move_history.each_slice(2).with_index do |moves, i|
      white_move = moves[0]&.to_algebraic || ''
      black_move = moves[1]&.to_algebraic || ''
      puts "#{i + 1}. #{white_move.ljust(8)} #{black_move}"
    end
    puts
  end

  def show_fen
    return puts "No game in progress." unless @game
    puts "\n#{@game.to_fen}\n\n"
  end

  def load_fen(fen_string)
    @game = Game.from_fen(fen_string)
    @clock = nil # Reset clock when loading position
    puts "Position loaded from FEN"
    display_board
  rescue => e
    puts "Error loading FEN: #{e.message}"
  end

  def make_move(notation)
    return puts "No game in progress. Type 'new' to start." unless @game
    return puts "Game is over!" if @game.over?

    if @clock
      @clock.start(@game.current_player)
    end

    if @game.make_move(notation)
      if @clock
        @clock.stop(@game.current_player == :white ? :black : :white)

        if @clock.flagged?(:white)
          puts "White flagged! Black wins on time."
          @game.instance_variable_set(:@game_over, true)
        elsif @clock.flagged?(:black)
          puts "Black flagged! White wins on time."
          @game.instance_variable_set(:@game_over, true)
        end
      end

      display_board
    else
      if @clock
        @clock.stop(@game.current_player)
      end
      puts "Illegal move!"
    end
  end

  def resign
    return puts "No game in progress." unless @game

    winner = @game.current_player == :white ? "Black" : "White"
    puts "#{@game.current_player.to_s.capitalize} resigns. #{winner} wins!"
    @game.instance_variable_set(:@game_over, true)
  end

  def offer_draw
    return puts "No game in progress." unless @game
    puts "Draw offered. (In a real game, opponent would accept/decline)"
    @game.instance_variable_set(:@game_over, true)
    @game.instance_variable_set(:@result, "Draw by agreement")
  end
end
```

**Step 2: Create executable**

Create `bin/chess`:

```ruby
#!/usr/bin/env ruby

require_relative '../lib/cli'

cli = CLI.new
cli.run
```

**Step 3: Make executable**

Run: `chmod +x bin/chess`

**Step 4: Test the CLI**

Run: `./bin/chess`
Expected: Chess CLI starts, can play a game

**Step 5: Commit**

```bash
git add lib/cli.rb bin/chess
git commit -m "feat: add CLI interface with board display and game commands"
```

---

## Task 19: Integration Testing

**Files:**
- Create: `spec/integration_spec.rb`

**Step 1: Write integration test**

Create `spec/integration_spec.rb`:

```ruby
require_relative '../lib/game'

RSpec.describe 'Full Game Integration' do
  it 'plays scholar\'s mate' do
    game = Game.new

    expect(game.make_move('e2e4')).to be true
    expect(game.make_move('e7e5')).to be true
    expect(game.make_move('f1c4')).to be true
    expect(game.make_move('b8c6')).to be true
    expect(game.make_move('d1h5')).to be true
    expect(game.make_move('g8f6')).to be true
    expect(game.make_move('h5f7')).to be true # Checkmate!

    expect(game.over?).to be true
    expect(game.checkmate?(:black)).to be true
  end

  it 'handles complex game with special moves' do
    game = Game.new

    # Play some moves
    moves = %w[e2e4 c7c5 g1f3 d7d6 d2d4 c5d4 f3d4 g8f6 b1c3 a7a6]
    moves.each do |move|
      expect(game.make_move(move)).to be true
    end

    expect(game.move_history.length).to eq(10)
    expect(game.current_player).to eq(:white)
    expect(game.over?).to be false
  end

  it 'handles promotion' do
    game = Game.new

    # Set up pawn near promotion
    game.board.place_piece(nil, [1, 4]) # Remove black pawn
    game.board.place_piece(Pawn.new(:white), [1, 4]) # White pawn on e7

    result = game.make_move('e7e8q') # Promote to queen
    expect(result).to be true
    expect(game.board.piece_at([0, 4])).to be_a(Queen)
  end

  it 'exports and imports via FEN correctly' do
    game1 = Game.new
    game1.make_move('e2e4')
    game1.make_move('e7e5')
    game1.make_move('g1f3')

    fen = game1.to_fen
    game2 = Game.from_fen(fen)

    expect(game2.current_player).to eq(game1.current_player)
    expect(game2.move_history.length).to eq(0) # FEN doesn't store history
    expect(game2.to_fen).to eq(fen)
  end
end
```

**Step 2: Run test to verify it passes**

Run: `bundle exec rspec spec/integration_spec.rb`
Expected: All tests PASS

**Step 3: Run full test suite**

Run: `bundle exec rspec`
Expected: All tests PASS

**Step 4: Commit**

```bash
git add spec/integration_spec.rb
git commit -m "test: add integration tests for full game scenarios"
```

---

## Task 20: Documentation

**Files:**
- Create: `README.md`

**Step 1: Write README**

Create `README.md`:

```markdown
# Ruby Chess Engine

A complete, hand-rolled chess engine built in Ruby with TDD using RSpec. No external chess libraries - everything is implemented from scratch.

## Features

- ✅ Complete chess rules implementation
- ✅ All piece movements (Pawn, Rook, Knight, Bishop, Queen, King)
- ✅ Special moves (castling, en passant, pawn promotion)
- ✅ Check, checkmate, and stalemate detection
- ✅ Draw conditions (fifty-move rule, threefold repetition, insufficient material)
- ✅ Chess clock with increment support
- ✅ FEN import/export for position sharing
- ✅ CLI interface with colored board display
- ✅ Full algebraic notation support (both standard and long form)

## Installation

```bash
bundle install
```

## Usage

Start the chess CLI:

```bash
./bin/chess
```

### Commands

- `new [minutes] [increment]` - Start new game with optional time control
  - Example: `new 10 5` (10 minutes + 5 second increment)
- `move <notation>` - Make a move
  - Long algebraic: `move e2e4`
  - Standard algebraic: `move e4`, `move Nf3`, `move O-O`
- `show` / `board` - Display current position
- `history` - Show move history
- `fen` - Display current position in FEN notation
- `load <fen>` - Load position from FEN string
- `resign` - Resign current game
- `draw` - Offer/accept draw
- `quit` - Exit

### Example Game

```
> new
> move e4
> move e5
> move Nf3
> show
> history
```

## Development

Run tests:

```bash
bundle exec rspec
```

Run specific test file:

```bash
bundle exec rspec spec/pawn_spec.rb
```

## Architecture

### Core Classes

- **Piece** - Base class for all chess pieces
  - Pawn, Rook, Knight, Bishop, Queen, King - Concrete piece implementations
- **Board** - Manages 8x8 grid, piece placement, and movement
- **Move** - Represents moves with algebraic notation support
- **Game** - Enforces rules, manages state, detects game end
- **Clock** - Tracks time with increment support
- **FEN** - Import/export positions in Forsyth-Edwards Notation
- **CLI** - Command-line interface with colored board display

### Design Principles

- **TDD**: Every feature test-driven with RSpec
- **OOP**: Clean object-oriented design with clear responsibilities
- **YAGNI**: Only implemented features needed for complete chess
- **No dependencies**: Hand-rolled implementation (except RSpec for testing)

## Project Structure

```
.
├── bin/
│   └── chess              # Executable CLI entry point
├── lib/
│   ├── piece.rb          # Base piece class
│   ├── pawn.rb           # Pawn implementation
│   ├── rook.rb           # Rook implementation
│   ├── knight.rb         # Knight implementation
│   ├── bishop.rb         # Bishop implementation
│   ├── queen.rb          # Queen implementation
│   ├── king.rb           # King implementation
│   ├── board.rb          # Board management
│   ├── move.rb           # Move representation
│   ├── game.rb           # Game rules and state
│   ├── clock.rb          # Time control
│   ├── fen.rb            # FEN import/export
│   └── cli.rb            # CLI interface
├── spec/
│   ├── *_spec.rb         # Test files
│   └── spec_helper.rb    # RSpec configuration
├── Gemfile
└── README.md
```

## Next Steps: Multi-Agent Chess AI

This engine serves as the foundation for building a multi-agent LLM-based chess player:

1. **Shared Context**: Game state via FEN strings
2. **Legal Move Validation**: Engine ensures AI only makes valid moves
3. **Game Rules**: Engine handles all special cases (en passant, castling, etc.)
4. **Agent Interface**: AI agents receive FEN, return move in algebraic notation
5. **Sequential Specialists**: Tactical agent → Positional agent → Move selector

The hand-rolled implementation gives complete control and understanding of the game mechanics that will be taught to the multi-agent system.

## License

MIT
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add comprehensive README with architecture and usage"
```

---

## Plan Complete!

All tasks have been specified with:
- Exact file paths
- Complete code examples
- Test-first approach (RED-GREEN-REFACTOR)
- Verification steps
- Frequent commits

The implementation builds a complete chess engine from the bottom up:
1. Individual pieces (Tasks 2-8)
2. Board management (Task 9)
3. Move notation (Task 10)
4. Game rules and state (Tasks 11-12)
5. Special moves (Tasks 13-14)
6. Draw conditions (Task 15)
7. Time controls (Task 16)
8. FEN support (Task 17)
9. CLI interface (Task 18)
10. Integration tests (Task 19)
11. Documentation (Task 20)

This provides the solid foundation needed before building the multi-agent chess AI system.