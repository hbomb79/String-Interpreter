# frozen_string_literal: true

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
# Assignment 1 - Harry Felton - 18032692

# Add our lib directory to require path
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"

require 'core/interpreter'

interpreter = Interpreter.new
interpreter.open
