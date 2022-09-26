$OPTIONS = ["1","2","3","4","5","6"]
$MAX_TURNS = 12

#
class GameRound
  attr_accessor :turn, :pattern, :guess, :exact_match, :value_matches, :position_matches, :hint

  def initialize()
    @turn = 1
    @pattern = {}
    @guess = {}
    @exact_match = false
    @value_matches = {}
    @position_matches = {}
    @hash_match = {}
    @hint = []
  end

  def get_code_auto
    4.times do |i|
      @pattern[i] = $OPTIONS.sample 
    end
    #puts @pattern
  end

  #Prompt user for input, validate number [1-6]
  def ask_for_guess(turn)
    4.times do |i|
      puts "Turn #{@turn}: Please enter your guess (1-6) for position #{i}"
      @guess[i] = gets.chomp.to_s
      if /[1-6]/ =~ @guess[i] && @guess[i].to_i < 7
        "Position one: #{@guess[i]}"
      else
        puts "Invalid input. Please enter a number (1-6)"
        redo
      end
    end
    puts "Your guess: #{@guess}"
  end

  #Check user input for matches with pattern
  def check_guess
    #Secondary arrays that will store guess and pattern positions that are not matches
    #Allows second evaluation to check for partial matches
    guess_array = @guess.values
    pattern_array = @pattern.values

    #Exact match
    if @guess == @pattern
      puts "Wow! You got it exactly right! You win!"
      puts "You're the Mastermind now, dog!"
      @exact_match = true
    else
      4.times do |i|
        #Correct number in correct place
        if @guess[i] == @pattern[i]
          @value_matches[i] = true
          @position_matches[i] = true
          guess_array[i] = "X" #Dont double count a match
          pattern_array[i] = "Y" #Remove both from secondary array to check for non-exact matches
        else
          #Set any non-match pair to false before moving on to secondary evaluation
          @value_matches[i] = false
          @position_matches[i] = false
        end
      end

      #Perform secondary evaluation on array to check for partial matches
      4.times do |i|  
        if pattern_array.any?(guess_array[i])
          @value_matches[i] = true
          @position_matches[i] = false unless @position_matches[i] == true
        end
      end
    end
  end

  #Evaluate match arrays and create feedback for user
  def create_hint(values, positions)
    4.times do |i|
      if [values[i],positions[i]].all?(true) #exact match
        #puts "This worked"
        hint[i] = "X"
      elsif values[i] == true
        hint[i] = "~"
      else
        hint[i] = "."  
      end
    end
    p hint.sort_by {|w| (w == "~") ? 0 : 1}.sort_by {|x| (x == "X") ? 0 : 1} #"X" comes first, then "~", then "."
  end

  
  #Print game rules to screen
  def greeting
    puts "Get ready to play Mastermind!"
    puts "The Mastermind Codemaker has selected 4 random numbers between [1-6] (duplicates allowed)"
    puts "Each number has been placed in a position labeled [0-3]"
    puts "Can you guess the correct combination before your #{$MAX_TURNS} turns run out?"
    puts "After each guess, the Mastermind will give you a hint about how you're doing."
    puts "An 'X' means you got a number in the correct position"
    puts "A '~' means 'ALMOST', as in you found a correct number but not in the correct position"
    puts "A '.' means you got a guess completely wrong"
    puts "Hints are NOT in the same order as your guess. Hints will always have the order: X, ~ , ."
    puts "Your time begins....now."
  end
  
  #Print loss to screen and exit program
  def out_of_turns
    puts "Codemaker wins!"
    puts "The code was #{@pattern}"
    exit
  end
  
  #Main game loop
  def begin_game
    self.get_code_auto
    self.greeting 

    while @turn <= $MAX_TURNS && !@exact_match
      self.ask_for_guess(@turn) 
      self.check_guess
      if !@exact_match
        self.create_hint(@value_matches, @position_matches) 
        @turn += 1
      end
    end
    if @turn > 12
      out_of_turns
    end
  end
end

game =  GameRound.new
game.begin_game

