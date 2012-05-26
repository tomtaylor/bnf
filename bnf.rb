require 'sinatra'
require 'sequel'

DB = Sequel.sqlite('drugs.db')

get '/' do
  @drugs = DB[:drugs].order(:name).all
  erb :index
end