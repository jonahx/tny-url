# Unlikely collisions: 62^6x 56800235584
#   Could: Put hash logic in a db trigger
#          Do a transaction where you check first then insert
#
# Mount API at api/ and the webapp at the root
# Make them proper sinatra apps

require 'sinatra'
require_relative './domain/validated_url'
require_relative './repo'

class API < Sinatra::Base

  set :show_exceptions, false

  # see README for unlikely but theoretically possible error here
  post '/shorten' do
    raise 'blah'
    data = JSON.parse(request.body.read)
    Repo.insert_url(
      ValidatedUrl.new(data['url'], data['short_name'])
    ).to_json
  end

  error InvalidUrl, InvalidShortName, ShortNameUnavailable do
    status 400
    client_error_json(env['sinatra.error'].message)
  end

  # automatically returns 500 for uncaught errors
  error do
    server_error_json(env['sinatra.error'].message)
  end

  # automatically returns 404
  not_found do
    client_error_json('Unknown route')
  end


  def success_json(data)
    {status: 'success', data: data}.to_json
  end

  def client_error_json(msg)
    {status: 'fail', message: msg}.to_json
  end

  def server_error_json(msg)
    {status: 'error', message: msg}.to_json
  end

end
