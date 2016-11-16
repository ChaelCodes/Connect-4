class Board < ActiveRecord::Base
    def players
        return [1, 2]
    end
    
    #Get a 2D Array version of the board for display, and modification
    def board_grid
        board_grid = []
        rows = self.board_state.split('|') 
        rows.each { |row|
          board_grid.push(row.split('^'))
        }
        return board_grid
    end
    
    def bottom_of_column(column)
      board_grid = self.board_grid
      (0...6).reverse_each { |row|
        if board_grid[row][column] == "0"
          return row
        end
      }
      return false
    end
    
    def find_valid_moves
      valid_moves = []
      (0...7).each { |column|
        row = self.bottom_of_column(column)
        if (row)
          valid_moves << {row: row, column: column}
        end
      }
      return valid_moves
    end
end
