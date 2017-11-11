# NOTE: These tests implicitly test the lower level object FullUrl,
#       ShortName, and OwnersSecret, which RequestedShortening delegates
#       to, and so testing those separately is probably overkill

require 'minitest/autorun'
require_relative '../domain/requested_shortening'

class RequestedShorteningTest < Minitest::Test

  #########################
  # Does it catch bad data?
  #########################

  def test_raises_if_not_a_url
    assert_raises(InvalidUrl) do
      RequestedShortening.new('xxx')
    end
  end

  def test_raises_if_url_too_long
    assert_raises(InvalidUrl) do
      RequestedShortening.new("http://#{'a'*2000}.com")
    end
  end

  def test_raises_if_short_name_too_long
    assert_raises(InvalidShortName) do
      RequestedShortening.new('http://x.com', 'a'*31)
    end
  end

  def test_raises_if_short_name_has_bad_chars
    assert_raises(InvalidShortName) do
      RequestedShortening.new('http://x.com', 'abc**&')
    end
  end

  def test_stores_valid_short_name
    shortening = RequestedShortening.new('http://x.com', 'good-short-name')
    assert_equal('good-short-name', shortening.short_name)
  end

  def test_stores_valid_url
    shortening = RequestedShortening.new('http://x.com', 'good-short-name')
    assert_equal('http://x.com', shortening.full_url)
  end

  ###############################
  # Does it create random hashes?
  ###############################

  # NOTE: these will fail randomly with a very tiny probability
  #       but in exchange we get a non-brittle test decoupled
  #       from the hash implementation

  def test_creates_random_short_name_if_not_given
    num_trials = 1e4
    uniq_names = (1..num_trials).map do
      RequestedShortening.new('http://x.com').short_name
    end.uniq
    assert_equal(num_trials, uniq_names.size,
                 'Generated short names should not collide')
  end

  def test_creates_random_owners_secret
    num_trials = 1e4
    uniq_names = (1..num_trials).map do
      RequestedShortening.new('http://x.com').owners_secret
    end.uniq
    assert_equal(num_trials, uniq_names.size,
                 'Generated owners secrets should not collide')
  end
end
