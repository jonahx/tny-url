require 'rack'
require 'rack/contrib'
require_relative './api_app'
require_relative './frontend_app'

$stdout.sync = true

run Rack::URLMap.new(
  '/' => FrontendApp.new,
  "/api" => ApiApp.new
)
