require 'sinatra'
require_relative './constants'
require_relative './repo'
require_relative './domain/requested_shortening'
require_relative './domain/short_name'
require_relative './domain/owners_secret'

class FrontendApp < Sinatra::Base

  use Rack::PostBodyContentTypeParser # put json body into params hash

  set :show_exceptions, false

  get '/:short_name' do
    begin
      short_name = ShortName.new(params[:short_name])
      found = Repo.lookup_by_short_name(short_name)
      redirect found.full_url, 301
    rescue ShortNameNotFound, InvalidShortName => e
      erb :shorten_link, locals: {error_message: e.to_s}
    end
  end

  get '/' do
    erb :shorten_link
  end

  not_found do
    client_error_json('Unknown route')
  end

  error do
    server_error_json('An unexpected server error occurred')
  end

  def full_url(path)
    Constants.full_url(path)
  end

  def success_json(data)
    {status: 'success', data: data}.to_json
  end

  def client_error_json(msg)
    {status: 'fail', message: msg}.to_json
  end

  def client_error(http_status, msg)
    status http_status
    {status: 'fail', message: msg}.to_json
  end

  def server_error_json(msg)
    {status: 'error', message: msg}.to_json
  end

end
