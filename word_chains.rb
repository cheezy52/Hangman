require 'set'

class WordChains
  def initialize(start_word, target_word, dict_path = "dictionary.txt")
    @start_word = start_word
    @target_word = target_word
    @dictionary = File.readlines(dict_path).map(&:chomp)
    @words_to_expand = [start_word]
    @candidate_words = Set.new []
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
    might_be_words = []
    (0...word.length).each do |index|
      ("a".."z").each do |letter|
        temp_word = word.dup
        temp_word[index] = letter
        might_be_words << temp_word
      end
    end
    might_be_words.each do |word|
      if @candidate_words.include?(word)
        adjacent_words << word
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