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
    @winner = has_player_won(1, @board_grid)
    @loser = has_player_won(2, @board_grid)
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
    player = params[:player]
    valid_move = make_move(column, player)
    if (valid_move)
      unless has_player_won(player, @board.board_grid)
        move = find_best_move(2, @board.board_grid)
        make_move(move[:column], 2)
      end
      @board.update(params.permit(:board_state))
      respond_to do |format|
        format.html { redirect_to @board, notice: "Board was successfully updated" }
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
    def has_player_won(player, board_grid)
      return has_connected_four_horizontally(player, board_grid) || has_connected_four_vertically(player, board_grid) || has_connected_four_diagonally(player, board_grid)
    end

    #This is repetetive, and hideous, but I feel pressured to return results soon.
    def has_connected_four_horizontally(player, board_grid)
      player = player.to_s
      (0...6).each { |r| #row
        (0...4).each { |c| #column
          if (board_grid[r][c] == player and board_grid[r][c+1] == player and board_grid[r][c+2] == player and board_grid[r][c+3] == player)
            return true
          end
        }
      }
      return false
    end
    
    def has_connected_four_vertically(player, board_grid)
      player = player.to_s
      (0...3).each { |r| #row
        (0...7).each { |c| #column
          if (board_grid[r][c] == player and board_grid[r+1][c] == player and board_grid[r+2][c] == player and board_grid[r+3][c] == player)
            return true
          end
        }
      }
      return false
    end
    
    def has_connected_four_diagonally(player, board_grid)
      player = player.to_s
      (0...3).each { |r| #row
        (0...4).each { |c| #column
          if (board_grid[r][c] == player and board_grid[r+1][c+1] == player and board_grid[r+2][c+2] == player and board_grid[r+3][c+3] == player)
            return true
          end
        }
      }
      (3...6).each { |r| #row
        (0...4).each { |c| #column
          if board_grid[r][c] == player and board_grid[r-1][c-1] == player and board_grid[r-2][c-2] == player and board_grid[r-3][c-3] == player
                return true
          end
        }
      }
      return false
    end

    def make_move(column, player)
      board_grid = @board.board_grid
      row = @board.bottom_of_column(column)
      return false unless row
      board_grid[row][column] = player
      board_grid.collect! { |r| #row
        r = r.join('^')
      }
      @board.board_state = board_grid.join('|')
    end
 
    def find_best_move(player, board_grid, depth=4)
      valid_moves = @board.find_valid_moves
      if (depth == 0)
        return { column: valid_moves[0][:column] }
      end
      player = player.to_s
      other_player = player == "1" ? "2" : "1"
      
      moves = []
      
      #Win or Lose Loop
      valid_moves.each { |move|
        hypothetical_board_grid = board_grid
        row = move[:row]
        column = move[:column]
        hypothetical_board_grid[row][column] = player
        if (has_player_won(player, board_grid))
          return {column: column, outcome: 'Victory'}
        end
        hypothetical_board_grid[row][column] = other_player
        if (has_player_won(other_player, hypothetical_board_grid))
          moves << { row: row, column: column }
        end
      }
      
      #Moves that allow my oponent to win
      if (moves.length == 0)
        valid_moves.each { |move|
          hypothetical_board_grid = board_grid
          row = move[:row]
          column = move[:column]
          hypothetical_board_grid[row][column] = player
          hypothetical_move = find_best_move(other_player, hypothetical_board_grid, depth - 1)
          if (hypothetical_move[:outcome] != 'Victory')
            moves << { row: row, column: column }
          end
        }
      end
      return {column: moves[0][:column], outcome: 'Game Continues'}
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
