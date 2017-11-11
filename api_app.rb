require 'sinatra'
require_relative './constants'
require_relative './repo'
require_relative './domain/requested_shortening'
require_relative './domain/short_name'
require_relative './domain/owners_secret'

class ApiApp < Sinatra::Base

  use Rack::PostBodyContentTypeParser # put json body into params hash

  set :show_exceptions, false

  before do
    content_type 'application/json'
  end

  post '/shortened-urls' do
    begin
      saved = Repo.insert_shortened_url(
        RequestedShortening.new(params[:full_url], params[:short_name])
      )
      success_json({
        shortUrl: full_path(saved.short_name),
        fullUrl: saved.full_url,
        deleteUrl: full_path("delete/" + saved.owners_secret)
      })
    rescue InvalidUrl, InvalidShortName, ShortNameUnavailable => e
      client_error(400, e)
    end
  end

  get '/shortened-urls/:short_name' do
    begin
      found = Repo.lookup_by_short_name(ShortName.new(params[:short_name]))
      success_json({
        shortUrl: full_path(found.short_name),
        fullUrl: found.full_url
      })
    rescue ShortNameNotFound, InvalidShortName => e
      client_error(400, e)
    end
  end

  delete '/shortened-urls/:short_name' do
    begin
      raise OwnersSecretRequired unless params[:owners_secret]
      Repo.delete_url(
        ShortName.new(params[:short_name]),
        OwnersSecret.new(params[:owners_secret])
      )
      status 204 # successfully deleted
    rescue ShortNameNotFound, OwnersSecretRequired, InvalidOwnersSecret => e
      client_error(400, e)
    rescue IncorrectSecret => e
      client_error(403, e)
    rescue AlreadyDeleted => e
      client_error(410, e)
    end
  end

  not_found do
    client_error_json('Unknown route')
  end

  error do
    server_error_json('An unexpected server error occurred')
  end

  def full_path(path)
    Constants.full_path(path)
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
