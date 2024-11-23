class MazeController < ApplicationController
  def index
    width = params[:width].to_i
    height = params[:height].to_i

    # Default maze dimensions if none provided
    width = 4 if width <= 0
    height = 4 if height <= 0

    @maze = generate_jumping_julia_maze(width, height)
  end

  private

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
