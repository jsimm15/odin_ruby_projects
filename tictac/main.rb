require_relative 'tictac.rb'

#Initialize GameBoard and GameRound Objects. Call begin_game
grid = GameBoard.new
game = GameRound.new(grid)
game.begin_game()