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
    @parents = {}
  end

  def build_path
    path = []
    current_word = @target_word
    until current_word == @start_word
      p current_word
      path << current_word
      current_word = @parents[current_word]
    end
    path << @start_word
    path.reverse
  end

  def find_chain
    current_word = ""
    until @words_to_expand.empty? || current_word == @target_word
      current_word = @words_to_expand.shift
      adjacent_words = self.adjacent_words(current_word)
      adjacent_words.each do |word|
        @words_to_expand << word
        @reachable_words << word
        @candidate_words.delete(word)
        @parents[word] = current_word
      end
    end
    @reachable_words.include?(@target_word) ? build_path : nil
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
  p rubyduck.find_chain
end