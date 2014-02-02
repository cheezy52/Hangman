class Game
	def initialize(guessing_player, checking_player, max_misses = 6)
    @guessing_player = guessing_player
    @checking_player = checking_player
    @max_misses = max_misses
    @word_length = 0
    @revealed_word = ""
    @misses = 0
    @guessed_letters = []
	end

  def play
    self.clear_state
    @word_length = @checking_player.pick_secret_word
    self.create_blank_word
    puts @revealed_word
    @guessing_player.receive_secret_length(@word_length)
    until self.over?
      current_guess = @guessing_player.guess
      result_indices = @checking_player.check_guess(current_guess)
      @guessing_player.handle_guess_response(current_guess, result_indices)
      self.update_revealed_word(current_guess, result_indices)
      @misses += 1 if result_indices == []
      self.display_state
    end
    puts "Game over."
  end

  def over?
    if @misses > @max_misses
      puts "Guessing player loses.    Word was #{@checking_player.get_secret_word}"
      return true
    elsif @revealed_word.count("_") == 0
      puts "Guessing player wins!"
      return true
    end
    false
  end

  def clear_state
    @misses = 0
    @word_length = 0
    @revealed_word = ""
    @guessed_letters = []
  end

  def create_blank_word
    @word_length.times { @revealed_word << "_" }
  end

  def display_state
    self.display_hangman
    puts "Letters guessed: #{@guessed_letters.sort.join(", ")}"
    puts "#{@revealed_word}"
  end

  def display_hangman
    #Placeholder until snazzy graphics are included
    puts "Misses: #{@misses}.  Remaining misses allowed: #{@max_misses - @misses}"
  end

  def update_revealed_word(guess, indices)
    indices.each { |index| @revealed_word[index] = guess }
    @guessed_letters << guess
  end
end

class Player
  def initialize
    @word_length = 0
    @guessed_letters = []
  end
end

class HumanPlayer < Player
  def pick_secret_word
    self.clear_state
    puts "Enter the length of your secret word, as a number.  Do NOT enter the word itself."
    @word_length = gets.chomp.to_i
  end

  def receive_secret_length(length)
    self.clear_state
    puts "The word you are guessing is #{length} characters long."
  end

  def guess
    puts "Enter a letter to guess."
    valid_guess = false
    until valid_guess
      input = gets.chomp
      valid_guess = validate_guess_input(input)
    end
    @guessed_letters << input
    input
  end

  def validate_guess_input(input)
    if !("a".."z").include?(input)
      puts "Input invalid.  Please enter only one a-z character."
      return false
    elsif @guessed_letters.include?(input)
      puts "Letter already guessed.  Please guess a new letter."
      return false
    else
      return true
    end
  end

  def check_guess(guess)
    puts "Other player guessed '#{guess}'.  At what indices does '#{guess}' appear?"
    puts "(Entry format: '0, 3, 5'.  If letter does not appear, press Enter/Return.)"
    #Future Work: Add input validation at this step
    result_indices_as_strings = gets.chomp.split(", ")
    result_indices = result_indices_as_strings.map(&:to_i)
  end

  def handle_guess_response(guess, indices)
    #Display of revealed word is handled by Game, and will be done right after this step
    if indices == []
      puts "The word does not include your guess '#{guess}'."
    else
      puts "Your guess '#{guess} appeared at indices #{indices.join(", ")}."
    end
  end  

  def clear_state
    @guessed_letters = []
    @word_length = 0
  end

  def get_secret_word
    puts "What was your secret word?"
    gets.chomp
  end
end

class ComputerPlayer < Player
	def initialize(dict_path = "dictionary.txt")
    @dictionary = File.readlines(dict_path).map(&:chomp)
    @secret_word = ""
    @word_length = 0
    #Computer keeps track of revealed_word separately from Game for dict filtering
    #Duplication of state-tracking between Game and ComputerPlayer should prob. be refactored
    @revealed_word = ""
    @guessed_letters = []
    @remaining_letters = []
    ("a".."z").each { |char| @remaining_letters << char }
    @possible_words = []
  end

  def pick_secret_word
    self.clear_state
    valid_word = false
    #Pick new word if word contains non a-z characters
    until valid_word
      valid_word = true
      secret_word = @dictionary.sample
      secret_word.split("").each do |char|
        #@remaining_letters at this point is always all a-z characters
        valid_word = false unless @remaining_letters.include?(char)
      end
      @secret_word = secret_word if valid_word
    end
    @word_length = @secret_word.length
  end

  def receive_secret_length(length)
    self.clear_state
    @word_length = length
    self.create_blank_word
    @dictionary.each do |word|
      @possible_words << word if word.length == length
    end
  end

  def guess
    letter_frequencies = {}
    @remaining_letters.each { |letter| letter_frequencies[letter] = 0 }
    @possible_words.each do |word|
      word.split("").each do |letter|
        if letter_frequencies.keys.include?(letter)
          letter_frequencies[letter] += 1
        end
      end
    end
    guess = letter_frequencies.key(letter_frequencies.values.max)
    @guessed_letters << guess
    @remaining_letters.delete(guess)
    guess
  end

  def check_guess(guess)
    matched_indices = []
    @secret_word.split("").each_with_index do |char, index|
      matched_indices << index if char == guess
    end
    matched_indices
  end

  def handle_guess_response(guess, indices)
    indices.each do |index|
      @revealed_word[index] = guess
    end
    self.update_possible_words
  end

  def create_blank_word
    @word_length.times { @revealed_word << "_" }
  end

  def clear_state
    @secret_word = ""
    @word_length = 0
    @guessed_letters = []
    @remaining_letters = []
    ("a".."z").each { |char| @remaining_letters << char }
  end

  def get_secret_word
    @secret_word
  end

  def update_possible_words
    regex_string = ""
    @revealed_word.split("").each do |letter|
      if letter != "_"
        regex_string << letter
      else
        regex_string << "[^#{@guessed_letters.join("")}]"
      end
    end
    new_wordlist = []
    p regex_string
    @possible_words.each do |word|
      unless word.match(regex_string).nil?
        new_wordlist << word
      end
    end
    p new_wordlist
    @possible_words = new_wordlist
  end
end

if __FILE__ == $PROGRAM_NAME
  p1 = HumanPlayer.new;nil
  p2 = ComputerPlayer.new;nil
  hangman = Game.new(p2, p1);nil
  hangman.play
end