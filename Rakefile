require 'bundler/gem_tasks'
require 'rake/testtask'
require 'byebug'
require 'dotenv'
require 'dotenv/tasks'
require 'canson'
require 'canson/tasks'
Dotenv.load(File.expand_path('../.env', __FILE__))

Rake::TestTask.new(test: :dotenv) do |t|
  t.libs << 'spec'
  t.libs << 'lib'
  t.test_files = FileList['spec/**/*_spec.rb']
end
task :default => :test
