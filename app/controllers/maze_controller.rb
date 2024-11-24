class MazeController < ApplicationController
  def index
    width = params[:width].to_i
    height = params[:height].to_i

    # Default maze dimensions if none provided
    width = 4 if width <= 0
    height = 4 if height <= 0

    # @maze = generate_jumping_julia_maze(width, height)
    @maze = generate_solvable_julia_maze(rows: width, columns: height, min_jump: 1, max_jump: 3)
  end

  private

  # Recursive function to ensure solvability by backtracking
  def fill_maze(maze, x, y, rows, columns, min_jump, max_jump)
    # Base case: Reached bottom-right cell
    return true if (x == rows - 1) && (y == columns - 1)

    # Possible jump values to try, in random order to vary the maze
    jumps = (min_jump..max_jump).to_a.shuffle

    jumps.each do |jump|
      # Try moving in each direction with the current jump value
      directions = [[jump, 0], [0, jump], [-jump, 0], [0, -jump]]

      directions.each do |dx, dy|
        new_x = x + dx
        new_y = y + dy

        # Check if the move is within bounds and the cell is empty
        if new_x.between?(0, rows - 1) && new_y.between?(0, columns - 1) && maze[new_x][new_y].zero?
          maze[x][y] = jump

          # Recursively fill the maze from the new position
          return true if fill_maze(maze, new_x, new_y, rows, columns, min_jump, max_jump)

          # Backtrack if the move didn't lead to a solution
          maze[x][y] = 0
        end
      end
    end

    false
  end

  # Main function to generate a solvable Julia Jumping Maze matrix
  def generate_solvable_julia_maze(rows: 4, columns: 4, min_jump: 1, max_jump: 3)
    # Initialize the maze with zeros
    maze = Array.new(rows) { Array.new(columns, 0) }

    # Start filling the maze from the top-left corner
    fill_maze(maze, 0, 0, rows, columns, min_jump, max_jump)

    # Fill any remaining unvisited cells with random values
    maze.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        maze[i][j] = rand(min_jump..max_jump) if cell.zero?
      end
    end

    maze[columns - 1][rows - 1] = 'Goal'
    maze
  end



  # Method to generate a Jumping Julia Maze
  def generate_jumping_julia_maze(width, height)
    maze = Array.new(height) { Array.new(width) { rand(1..3) } }

    # Explicitly set the start and goal
    maze[0][0] = rand(1..3) # Start point
    maze[height - 1][width - 1] = 'Goal' # Goal point

    # Ensure the maze is solvable
    until solvable?(maze, width, height)
      maze = Array.new(height) { Array.new(width) { rand(1..3) } }
      maze[0][0] = rand(1..3)
      maze[height - 1][width - 1] = 'Goal'
    end

    maze
  end

  # Method to check if the maze is solvable using Breadth-First Search (BFS)
  def solvable?(maze, width, height)
    queue = [[0, 0]] # Start from the top-left corner
    visited = Array.new(height) { Array.new(width, false) }
    visited[0][0] = true

    while !queue.empty?
      x, y = queue.shift
      return true if x == width - 1 && y == height - 1 # Reached the goal

      steps = maze[y][x] # Number of jumps allowed from this cell

      # Check all 4 possible jump directions (right, left, down, up)
      [[x + steps, y], [x - steps, y], [x, y + steps], [x, y - steps]].each do |nx, ny|
        if nx.between?(0, width - 1) && ny.between?(0, height - 1) && !visited[ny][nx]
          queue << [nx, ny]
          visited[ny][nx] = true
        end
      end
    end

    false # If queue empties and goal not reached, maze is unsolvable
  end
end
