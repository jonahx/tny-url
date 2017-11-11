require 'uri'
require_relative './url_hash'

class InvalidUrl < RuntimeError
  def to_s
    "The URL is invalid, or exceeds the maximum length of 2000 characters"
  end
end

class FullUrl
  def initialize(url)
    raise InvalidUrl unless url =~ URI::regexp && url.size <= 2000
    @url = url
  end

  def to_s
    @url
  end
end
