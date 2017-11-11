require 'uri'
require_relative './url_hash'
require_relative '../util/error_class'

InvalidShortName = ErrorClass.new(
  "Short names must be 30 characters or fewer, and contain only letters, " +
  "numbers, and hyphens")

class ShortName
  def initialize(short_name=nil)
    short_name_given = short_name && !short_name.empty?
    raise InvalidShortName if short_name_given && !valid?(short_name)
    @short_name = short_name || UrlHash.new(6).to_s
  end

  def to_s
    @short_name
  end

  private

  def valid?(short_name)
    UrlHash.valid?(short_name) && short_name.size <= 30
  end
end
