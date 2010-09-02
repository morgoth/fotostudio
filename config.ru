require "rubygems"
require "bundler/setup"

require "sinatra"
require ::File.expand_path("../app", __FILE__)

run Sinatra::Application
