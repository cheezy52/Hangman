This is a terminal-based implementation of the game "Hangman".  Guess the other player's secret word, letter-by-letter, but don't miss too many times or the noose will tighten!

By default, the human player will be guessing a word picked by the computer player.  To change this, edit the "if __FILE__ == $PROGRAM_NAME" section of hangman.rb; you can play with any combination of human and computer players, with either player as the word-generator.  The first player passed to Game.new will be the guesser.

To play, navigate in the terminal to the containing folder and execute "ruby hangman.rb".  Ruby must be installed.