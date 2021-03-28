# frozen_string_literal: true

# Felton, Harry, 18032692, Assignment 1, 159.341

##
# String Processor Language
# -------------------------
#
# This program is used to demonstrate the use of a symbol table and general
# imperative language structure/principles.
#
# For this project a robust framework for language development, utilizing a tokenizer
# and parser, are used. This allows for easy expansion in the future of this language,
# and helps to demonstrate the relative complexity that a basic language can
# present when attempting to lex the input.
#
# This program will accept input from stdin, until the user hits enter (or a newline is found). The input
# is then tokenized/lexed - the provided tokens are then parsed for their meaning.
#
# Constants SPACE, TAB and NEWLINE are loaded at application setup, and are readonly symbols.
#
# Parser state is reset after every line of input. This is perfectly valid:
# > set one 'this is a string.'; print one; reverse one; print one; exit;
#

# Add our lib directory to require path
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"

require 'core/interpreter'

puts "----------------------------------------
 159.341 Assignment 1 Semester 1 2021
 Submitted by: Harry Felton, 18032692
----------------------------------------"

# Create and start the interpreter
interpreter = Interpreter.new
interpreter.open
