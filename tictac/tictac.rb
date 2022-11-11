#Each playable tile on the board is represented by a Square object
class Square
  attr_accessor :marker, :position, :selected
  def initialize(position, selected = false)
    @position = position #Position on board 1-9
    @selected = selected
    @marker = "[#{@position.to_i}]" #Changes from position number to X or O when selected
  end

  #Instance method to change Square::marker to X or O depending on who is active player
  def select_square(active_player)
    #Raise exception if square has already been selected
    if self.selected 
      raise StandardError.new "This square is already selected"
    end

    #Determine X for Player 1, O for Player 2
    case active_player
    when 1
      self.marker = "[X]"
    when 2
      self.marker = "[O]"
    end
    self.selected = true #Once selected, modify Square::selected flag
  end
end

#Each GameBoard consists of 9 Square Objects. There is not need for inheritance
class GameBoard
  attr_accessor :grid #Array containing 9 Square objects that make up game board
  
  def initialize
    @grid = []
    9.times do |i|
      self.grid.push(Square.new(i + 1))
    end
    self.print_board
  end
  
  #Prints updated board
  def print_board
    9.times do |i|
      if [3,6].any?(i) #Every 3 lines items a line break
        puts ""
      end
      print self.grid[i].marker
    end
    puts "" #Print line break
  end

end

#Each GameRound will be initialed with a GameBoard Object
class GameRound
  attr_accessor :turn, :win_con, :active_player
  
  def initialize(gameboard_object)
    @board = gameboard_object #current GameBoard instance
    @turn = 1 
    @win_con = false
    @active_player = 1 #Will be either 1 or 2. Start with Player 1
  end 

  def begin_game
    puts "Time to Tic-Tac-Toe!"
    puts "Pick a number to play"
    puts "Player 1 you are X!"
    puts "Player 2 you are O!"
    
    #Main game loop. Execute for no more than 9 selections
    while self.turn <= 9 && (!self.win_con)
      puts "Turn #{self.turn} Player #{self.active_player}:"
      selection = gets.chomp #User input
      puts "You chose square #{selection}"
       
      if /[0-9]/ =~ selection.to_s #Ensure number
        begin
          select_square(active_player, selection)
        rescue => e #Square::select_square will raise exception if selection not available
          p e #Display error 
          @board::print_board
          redo
        end
        #Valid selection entered. Print updated board, increment turnm and check for winner
        @board::print_board
        self.turn += 1
        winner = check_win_con #Will return "Player 1" or "Player 2" if win_con = true
        
        if @win_con == true
          puts "Game Over! #{winner} wins!"
          break 
        end
      else #User input was not numeric digit
        puts "Invalid input. Try again"
        redo
      end
      #If no winner after 9 turns, board is full, game is a tie
      if self.turn == 10
        puts "Looks like it's a draw!!!"
        puts "Game Over"
      end
    end
  end

  #Getter for active_player determined by instance method
  def active_player
    @@active_player = get_active_player(self.turn)
  end

  #Determine active_player based on turn number 
  def get_active_player(turn)
    if self.turn % 2 == 1
      return 1
    else
      return 2
    end
  end

  #Instance method to send player number to Square Object at specified position
  def select_square(active_player, grid_position)
      @board::grid[grid_position.to_i - 1]::select_square(active_player)
  end

  #Check for winner after each selection
  def check_win_con
    #Declare array winner consisting of 8 empty arrays
    row1, row2, row3, col1, col2, col3, diagup, diagdown = winners = Array.new(8) { [] }

    #List of squares inside GameBoardClass is zero-indexed!
    #Each group of 3 is a potential winning combination. Each appended array is a list of 3 Square::markers
    [0,1,2].each {|i| row1 << @board::grid[i]::marker}
    [3,4,5].each {|i| row2 << @board::grid[i]::marker}
    [6,7,8].each {|i| row3 << @board::grid[i]::marker}
    [0,3,6].each {|i| col1 << @board::grid[i]::marker}    
    [1,4,7].each {|i| col2 << @board::grid[i]::marker}
    [2,5,8].each {|i| col3 << @board::grid[i]::marker}
    [6,4,2].each {|i| diagup << @board::grid[i]::marker}
    [0,4,8].each {|i| diagdown << @board::grid[i]::marker}
    
    #p winners

    winners.each do |group|
      #puts "checking..."
      #p group
      #Check each group of 3 for all X's or all O's
      if group.all?("[X]")
        @win_con = true
        puts "Found winner"
        return "Player 1"
      elsif group.all?("[O]")
        @win_con = true
        puts "Found winner"
        return "Player 2"
      end
    end
    puts "No winner this round."
  end 
end

# #Initialize GameBoard and GameRound Objects. Call begin_game
# grid = GameBoard.new
# game = GameRound.new(grid)
# game.begin_game()