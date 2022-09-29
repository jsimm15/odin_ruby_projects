require 'yaml'

class GameRound
  attr_accessor :word_to_guess, :turns_remaining, :display, :guessed_letters, :game_state
  $word_list = File.readlines("word_dictionary.txt")
  
  def initialize()
    @turns_remaining = 6 #Start with 6 attempts
    @word_to_guess = ""
    @guessed_letters = []
  end
  
  #Main game loop
  def start_game()
    print_rules()

    @display = UserGuess.new(self.word_to_guess.string_rep)
    puts "Your word has been generated."
    @display.print_guess
    while turns_remaining > 0 
      puts "Tries remaining: #{@turns_remaining}"
      if !@guessed_letters.nil? 
        print_guessed_letters(@guessed_letters) 
      end
      puts "Enter a letter: "
      guess = gets.chomp
      puts ""
      check_guess(guess)
      @display.print_guess
    end

    if @turns_remaining == 0
      game_over()
    end
  end
  
  #Select random word from list
  def random_word()
    while true
      word = $word_list.sample.chomp.to_s
      if word.length >= 5 && word.length <= 12
       @word_to_guess = HiddenWord.new(word)
       break
      else #Continue selecting new word until parameters met
        redo
      end
    end
  end
  
  #Handle user input
  def check_guess(guess)
    #Array representation of solution
    arr = self.word_to_guess.arr_rep
    
    #Numbered exit codes
    if guess == '1' #Attempt to solve full word
      print "Enter full word guess: "
      word_guess = gets.chomp
      check_full_word(word_guess)
    elsif guess == '5' #Save game state
      save_game(self.turns_remaining, self.word_to_guess.string_rep, self.display.user_guess, self.guessed_letters)
      return "Game saved"
    elsif guess == '7' #Quit game
      exit
    elsif guess == '9' #Load game
      puts "Please enter the name of your saved game(no extension):"
      file = "saved_games/" + gets.chomp + ".yml"
      load_saved_game(file)
      return "Game loaded"
    elsif guess == '0' #Print rules to screen
      print_rules
    end

    ##Check f letter match in solution
    if /[A-Za-z]/ =~ guess && guess.length == 1
      if arr.include?(guess)
        puts "'#{guess}' Found!"
        arr.each_with_index do |ch, i|
          if arr[i] == guess
            @display.user_guess[i] = guess #Fill in correct letter in user display
            add_guessed_letter(guess)
          end
        end
      else 
        puts "'#{guess}' NOT FOUND!"
        add_guessed_letter(guess)
        @turns_remaining -= 1
      end
    else
      puts "Invalid input. Try again."
    end
    #Letter match results in complete solution
    if @display.user_guess.join == self.word_to_guess.string_rep
      @display.print_guess
      win_game
    end
  end
  
  #Allow user to input full word guess
  def check_full_word(word)
    if word == self.word_to_guess.string_rep
      win_game()
    else
      puts "Incorrect!"
      @turns_remaining -= 1
    end
  end
  
  #Build array of previously guessed letters
  def add_guessed_letter(letter)
    @guessed_letters.push(letter) unless guessed_letters.include?(letter)
  end

  #Display array of previously guessed letters
  def print_guessed_letters(list)
    puts "Guessed letters: #{list}"
  end

  #Re-print input legend to screen
  def print_rules()
    puts "Enter a number:\n(1) to guess whole word\n(5) to save game"
    puts "(7) to quit game\n(9) to load game\n(0) to print rules"
    puts "Or enter any letter to guess a letter"
  end

  #Save game state as hash pairs, write to disk
  def save_game(turns, word, guess, letters)
    @game_state = SaveData.new(turns, word, guess, letters)

    print "Please enter a name for your saved game: "

    filename = "saved_games/#{gets.chomp}.yml" 

    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
    begin
      File.open(filename, 'w') do |file|
        file.write @game_state.save_hash.to_yaml
      end
      puts "Game saved in saved_games folder as #{filename}"
    rescue => exception
      puts "Error. Game not saved"
      p exception
    end
  end
  
  #Load previously saved game state
  def load_saved_game(filename)
    load_hash = YAML.load(File.read(filename)) #Load from yaml

    #Reinitialize game classes and variables
    @turns_remaining = load_hash[:turns]
    @word_to_guess = HiddenWord.new(load_hash[:word])
    @guessed_letters = load_hash[:letters]
    @display = UserGuess.new(load_hash[:word])
    @display.user_guess = load_hash[:guess]

  end

  #Win condition met
  def win_game
    puts "You did it! You correctly guessed the word in time!"
    exit
  end

  #Loss condition met
  def game_over
    puts "Game Over! It looks like you ran out of turns."
    puts "The word was '#{self.word_to_guess.string_rep}'"
    exit
  end
end

#Class holding string and array representations of word
class HiddenWord
  attr_reader :string_rep, :arr_rep
  
  def initialize(word)
    @string_rep =  word.to_s
    @arr_rep = []
    @arr_rep = to_arr_rep()
  end
  
  def to_arr_rep
    len = @string_rep.length
    len.times do |i|
      @arr_rep.push(@string_rep[i])
    end
    @arr_rep
  end
end

#Class for holding string of "_" characters matching the length of an input string
class UserGuess < HiddenWord
  attr_accessor :user_guess, :len
  
  def initialize(word)
    @user_guess = []
    @len = word.length
    len.times do |i|
      @user_guess << "_" 
    end
  end
  
  def print_guess()
    print "Word: "
    @len.times do |i|
      print "#{@user_guess[i]} "
    end
    puts ""
  end

end

#Class for holding save game data as hash table
class SaveData < GameRound
attr_accessor :save_hash
  def initialize(turns, word, guess, letters)
    @turns_remaining = turns
    @word = word
    @guess = guess
    @letters = letters
    @save_hash = {
      :turns=>turns,
      :word=>word,
      :guess=>guess,
      :letters=>letters
    }
  end
end

#Initialize game loop
game = GameRound.new
@word_to_guess = game.random_word()
game.start_game
