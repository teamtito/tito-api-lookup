require "rubygems"
require "bundler"
require "dotenv/load" if defined?(Dotenv)

Bundler.require

require "./lookup.rb"
run Lookup
