require 'uri'
require_relative './url_hash'
require_relative '../util/error_class'

InvalidOwnersSecret = ErrorClass.new('The secret is invalid')

class OwnersSecret
  def initialize(secret=nil)
    raise InvalidOwnersSecret if secret && !valid?(secret)
    @secret = secret || UrlHash.new(32).to_s
  end

  def valid?(secret)
    UrlHash.valid?(secret) && secret.size == 32
  end

  def to_s
    @secret
  end
end
