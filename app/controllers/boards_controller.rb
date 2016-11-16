class BoardsController < ApplicationController
  before_action :set_board, only: [:show, :edit, :update, :destroy, :drop_token]
  
  # GET /boards
  # GET /boards.json
  def index
    @boards = Board.all
  end

  # GET /boards/1
  # GET /boards/1.json
  def show
    @board_grid = get_board_state
    @winner = has_player_won
  end

  # GET /boards/new
  def new
    @board = Board.new
    @board.board_state = '0^0^0^0^0^0^0|0^0^0^0^0^0^0|0^0^0^0^0^0^0|0^0^0^0^0^0^0|0^0^0^0^0^0^0|0^0^0^0^0^0^0'
  end

  # GET /boards/1/edit
  def edit
    @board_grid = get_board_state
  end

  # POST /boards
  # POST /boards.json
  def create
    @board = Board.new(board_params)

    respond_to do |format|
      if @board.save
        format.html { redirect_to @board, notice: 'Board was successfully created.' }
        format.json { render :show, status: :created, location: @board }
      else
        format.html { render :new }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def make_best_move
    player = params[:player]
    drop_token({column: 1, player: player})
  end
  
  # POST boards/drop_token
  def drop_token
    column = params[:column].to_i
    player = params[:player].to_i
    board_grid = get_board_state

    (0...6).reverse_each { |i|
      if board_grid[i][column] == "0"
        board_grid[i][column] = player
        break
      end
    }
    board_grid.collect! { |row|
      row = row.join('^')
    }
    @board.board_state = board_grid.join('|')
    @board.update(params.permit(:board_state))
    respond_to do |format|
      format.html { redirect_to @board, notice: 'Board was successfully updated.' }
      format.json { render :show, status: :ok, location: @board }
    end
    change_turn player
  end
  
  # PATCH/PUT /boards/1
  # PATCH/PUT /boards/1.json
  def update
    respond_to do |format|
      if @board.update(board_params)
        format.html { redirect_to @board, notice: 'Board was successfully updated.' }
        format.json { render :show, status: :ok, location: @board }
      else
        format.html { render :edit }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boards/1
  # DELETE /boards/1.json
  def destroy
    @board.destroy
    respond_to do |format|
      format.html { redirect_to boards_url, notice: 'Board was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def has_player_won
      return has_connected_four_horizontally(1) || has_connected_four_vertically(1) || has_connected_four_diagonally(1)
    end

    def has_connected_four_horizontally(player)
      player = player.to_s
      board_grid = get_board_state
      (0...6).each { |r| #row
        (0...4).each { |c| #column
          if (board_grid[r][c] == player and board_grid[r][c+1] == player and board_grid[r][c+2] == player and board_grid[r][c+3] == player)
            return true
          end
        }
      }
      return false
    end
    
    def has_connected_four_vertically(player)
      player = player.to_s
      board_grid = get_board_state
      (0...3).each { |r| #row
        (0...7).each { |c| #column
          if (board_grid[r][c] == player and board_grid[r+1][c] == player and board_grid[r+2][c] == player and board_grid[r+3][c] == player)
            return true
          end
        }
      }
    end
    
    def has_connected_four_diagonally
      board_grid = get_board_state
      (0...6).each { |r| #row
        (0...7).each { |c| #column
          if board_grid[r][c] == player and board_grid[r+1][c+1] == player and board_grid[r+2][c+2] == player and board_grid[r+3][c+3] == player
            return true
          elsif board_grid[r][c] == player and board_grid[r-1][c-1] == player and board_grid[r-2][c-2] == player and board_grid[r-3][c-3] == player
            return true
          end
        }
      }
    end
    
    def change_turn(old_player)
      player = @board.players[old_player + 1]
      if player == 2
        make_best_move 2
      end
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_board
      @board = Board.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def board_params
      params.require(:board).permit(:board_state)
    end
    
    #Get a 2D Array version of the board for display, and modification
    def get_board_state
        @board_grid = []
        rows = @board.board_state.split('|') 
        rows.each { |row|
          @board_grid.push(row.split('^'))
        }
        return @board_grid
    end
end
