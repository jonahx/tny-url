require 'sequel'
require_relative './configured_db'
require_relative './constants'
require_relative './domain/shortened_url'
require_relative './domain/owners_secret'
require_relative './util/error_class'

ShortNameUnavailable = ErrorClass.new("The short name '{0}' is not available")
ShortNameNotFound = ErrorClass.new("The url '{0}' was not found")
AlreadyDeleted = ErrorClass.new("The resource '{0}' is already deleted")
IncorrectSecret = ErrorClass.new("Incorrect secret for resource '{0}'")
OwnersSecretRequired = ErrorClass.new(
  "Deletion requires a valid JSON owners_secret")

class Repo

  def self.insert_shortened_url(requested_shortening)
    ShortenedUrl.with(
      DB[:urls].insert_select(requested_shortening.to_h)
    )
  rescue Sequel::UniqueConstraintViolation
    raise ShortNameUnavailable.new(requested_shortening.short_name)
  end

  def self.lookup_by_short_name(short_name)
    found = where_short_name_is(short_name).where(deleted_on: nil).first
    raise ShortNameNotFound.new(url(short_name)) unless found
    ShortenedUrl.with(found)
  end

  def self.delete_url(short_name, owners_secret)
    found = where_short_name_is(short_name).first
    raise ShortNameNotFound.new(url(short_name)) unless found

    secret_matches = found[:owners_secret] == owners_secret.to_s
    raise IncorrectSecret.new(url(short_name)) unless secret_matches

    raise AlreadyDeleted.new(url(short_name)) unless found[:deleted_on].nil?

    # verified found and owned.  now we can safely delete
    where_short_name_is(short_name)
      .update(deleted_on: Sequel::CURRENT_TIMESTAMP)
  end

  private

  def self.url(short_name)
    Constants.full_path(short_name)
  end

  def self.where_short_name_is(short_name)
    DB[:urls].where(short_name: short_name.to_s)
  end
end
