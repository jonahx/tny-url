require 'values'
require 'json'

ShortenedUrl = Value.new(
  :id,
  :full_url,
  :short_name,
  :owners_secret,
  :created_on,
  :deleted_on
)
