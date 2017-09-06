require 'bundler'
require 'sinatra/json'
require 'sinatra/reloader'

Bundler.require

set :bind, '0.0.0.0'
set :port, 3000


post '/data' do
  new_data = params
  data = File.open("public/data.csv", "a+")
  data.truncate(0)
  data.puts("label,labelValue")
  new_data.each do |k , v|
    data.puts("#{k}, #{v}")
  end
  data.close
  puts "done"
end

get '/data' do
  data = File.read("public/data.csv")
  binding.pry
end

get '/' do
  File.read(File.join('public', 'index.html'))
end
