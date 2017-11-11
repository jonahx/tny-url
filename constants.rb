require 'sequel'

module Constants
  BASE_URL = 'http://localhost:3000'

  def self.full_path(path)
    "#{BASE_URL}/#{path}"
  end
end
