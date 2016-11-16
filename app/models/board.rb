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
end
