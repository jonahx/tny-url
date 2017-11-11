require 'sequel'

DB = Sequel.connect(
  ENV['RACK_ENV'] == 'production' ?
  ENV['DATABASE_URL'] :
  ENV['TEST_DATABASE_URL']
)
