$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'canson'
require "rack/test"
require 'byebug'
require 'minitest/mock'
require 'minitest/benchmark' if ENV['BENCH']
require 'minitest/reporters'
require 'minitest-vcr'
require 'minitest/autorun'
require 'vcr'
require 'webmock'
require "test_app_root/test_app.rb"
ENV["RACK_ENV"] = "test"


VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end


Minitest::Reporters.use!
MinitestVcr::Spec.configure!
