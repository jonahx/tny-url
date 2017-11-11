class UrlHash
  CHARS = [*'0'..'9', *'a'..'z', *'A'..'Z']

  def self.valid?(str)
    str =~ /^[a-zA-Z0-9\-]+$/
  end

  def initialize(num_chars)
    @hash = (1..num_chars).map { CHARS.sample }.join
  end

  def to_s
    @hash
  end
end
