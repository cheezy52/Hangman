class WordChains
  def initialize(start_word, target_word, dict_path = "dictionary.txt")
    @start_word = start_word
    @target_word = target_word
    @dictionary = File.readlines(dict_path).map(&:chomp)
    @words_to_expand = [start_word]
    @candidate_words = []
    self.populate_candidates
    @reachable_words = [start_word]
  end

  def explore_words
    until @words_to_expand.empty?
      current_word = @words_to_expand.shift
      adjacent_words = self.adjacent_words(current_word)
      adjacent_words.each do |word|
        @words_to_expand << word
        @reachable_words << word
        @candidate_words.delete(word)
      end
    end
    p @reachable_words
    @reachable_words.include?(@target_word)
  end

  def adjacent_words(word)
    adjacent_words = []
    #Using regex mostly for regex practice - slicing would work about as well
    regex_strings = []
    (0...word.length).each do |index|
      regex_strings[index] = word.dup
      regex_strings[index][index] = "."
    end
    @candidate_words.each do |word|
      regex_strings.each do |regex_string|
        if word.match(regex_string)
          adjacent_words << word
        end
      end
    end
    adjacent_words
  end

  def populate_candidates
    @dictionary.each do |word|
      @candidate_words << word if word.length == @start_word.length
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  rubyduck = WordChains.new("duck", "ruby");nil
  p rubyduck.explore_words
end