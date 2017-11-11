require 'sequel'

module Constants
  BASE_URL = ENV['app_name'] || 'http://localhost:3000'

  def self.full_path(path)
    "#{BASE_URL}/#{path}"
  end
end
