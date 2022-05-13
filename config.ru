require "rubygems"
require "bundler"
if ENV["RACK_ENV"] != "production"
  require "dotenv/load"
end

Bundler.require

require "./lookup.rb"
run Lookup
