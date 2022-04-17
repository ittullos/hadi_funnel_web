ENV['RACK_ENV'] = "test"

require_relative '../app/lambda'
require 'rack/test'
require 'rspec'
