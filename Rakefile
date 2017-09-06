require 'rake'
require 'rake/testtask'

task :env do
  require_relative 'boot'
end

task console: :env do
  pry
end

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
  t.libs    << 'test'
  t.warning = false
end

task default: :test
task spec: :test

# namespace :task do
#   desc "Run migrations"
#   task :myTask  do |t, args|
#     #rake task:myTask
#
#   end
# end
