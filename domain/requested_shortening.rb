require_relative './full_url'
require_relative './short_name'
require_relative './owners_secret'

class RequestedShortening
  attr_reader :full_url, :short_name, :owners_secret

  def initialize(full_url, requested_short_name=nil)
    @full_url = FullUrl.new(full_url).to_s
    @short_name = ShortName.new(requested_short_name).to_s
    @owners_secret = OwnersSecret.new.to_s
  end

  def to_h
    {
      full_url: @full_url,
      short_name: @short_name,
      owners_secret: @owners_secret
    }
  end
end
