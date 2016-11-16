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
    @board_grid = @board.board_grid
    @winner = has_player_won
  end

  # GET /boards/new
  def new
    @board = Board.new
    @board.board_state = '0^0^0^0^0^0^0|0^0^0^0^0^0^0|0^0^0^0^0^0^0|0^0^0^0^0^0^0|0^0^0^0^0^0^0|0^0^0^0^0^0^0'
  end

  # GET /boards/1/edit
  def edit
    @board_grid = @board.board_grid
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
  
  # POST boards/drop_token
  def drop_token
    column = params[:column].to_i
    player = params[:player].to_i
    valid_move = make_move(column, player)
    if (valid_move)
      make_best_move(player + 1)
      @board.update(params.permit(:board_state))
      respond_to do |format|
        format.html { redirect_to @board, notice: 'Board was successfully updated.' }
        format.json { render :show, status: :ok, location: @board }
      end
    else
      respond_to do |format|
        format.html { redirect_to @board, notice: 'Invalid Move' }
        format.json { render :show, status: :ok, location: @board }
      end
    end
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

    #This is repetetive, and hideous, but I feel pressured to return results soon.
    def has_connected_four_horizontally(player)
      player = player.to_s
      board_grid = @board.board_grid
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
      board_grid = @board.board_grid
      (0...3).each { |r| #row
        (0...7).each { |c| #column
          if (board_grid[r][c] == player and board_grid[r+1][c] == player and board_grid[r+2][c] == player and board_grid[r+3][c] == player)
            return true
          end
        }
      }
      return false
    end
    
    def has_connected_four_diagonally(player)
      board_grid = @board.board_grid
      (0...6).each { |r| #row
        (0...7).each { |c| #column
          if board_grid[r][c] == player and board_grid[r+1][c+1] == player and board_grid[r+2][c+2] == player and board_grid[r+3][c+3] == player
            return true
          elsif board_grid[r][c] == player and board_grid[r-1][c-1] == player and board_grid[r-2][c-2] == player and board_grid[r-3][c-3] == player
            return true
          end
        }
      }
      return false
    end
    
    def will_connect_four_horizontally(player)
      player = player.to_s
      board_grid = @board.board_grid
      (0...6).each { |r| #row
        (0...4).each { |c| #column
          if (board_grid[r][c+1] == player and board_grid[r][c+2] == player and board_grid[r][c+3] == player and (r == 0 or board_grid[r-1][c] != 0))
            return { row: r, column: c }
          end
        }
      }
      return false
    end
    
    def make_move(column, player)
      board_grid = @board.board_grid
      row = bottom_of_column(column)
      return false unless row
      board_grid[row][column] = player
      board_grid.collect! { |r| #row
        r = r.join('^')
      }
      @board.board_state = board_grid.join('|')
    end
    
    def bottom_of_column(column)
      board_grid = @board.board_grid
      (0...6).reverse_each { |row|
        if board_grid[row][column] == "0"
          return row
        end
      }
      return false
    end
      
    def make_best_move(player)
      valid_moves = find_valid_moves(player)
      make_move(valid_moves[0][:column], player)
      
      # #Deprecated
      # horizontal_threat = will_connect_four_horizontally(1)
      # if (horizontal_threat)
      #   make_move(horizontal_threat[:column], player)
      # else
      #   make_move(1, player)
      # end
    end
    
    def find_valid_moves(player)
      player = player.to_i
      valid_moves = []
      (0...6).each { |column|
        row = bottom_of_column(column)
        if (row)
          valid_moves << {row: row, column: column}
        end
      }
      return valid_moves
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_board
      @board = Board.find(params[:id])
    end

    # Define Board Parameters
    def board_params
      params.require(:board).permit(:board_state)
    end
end
