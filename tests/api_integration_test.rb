require 'minitest/autorun'
require 'rack/test'
require 'json'
require_relative '../api_app'

class ApiTest < Minitest::Test
  include Rack::Test::Methods

  def app
    ApiApp
  end

  # isolate our response parsing code
  def parsed_last_response
    JSON.parse(last_response.body)['data']
      .inject({}) { |m,(k,v)| m[k.to_sym] = v; m } #symbolize keys
  end

  def shorten(url)
    post(
      '/shortened-urls',
      {full_url: url}.to_json,
      {'CONTENT_TYPE' => 'application/json'}
    )
    parsed_last_response
  end

  def test_create_and_get
    full_url = 'http://some-long-url.com'

    # create a new short url
    resp1 = shorten(full_url)

    # make sure we can get it back
    get("/shortened-urls/#{resp1[:shortName]}")
    resp2 = parsed_last_response

    assert_equal(full_url, resp2[:fullUrl])
  end

  def test_delete_with_correct_secret
    full_url = 'http://some-long-url.com'

    # create a new short url
    resp1 = shorten(full_url)

    # delete it
    delete(
      "/shortened-urls/#{resp1[:shortName]}",
      {owners_secret: resp1[:ownersSecret]},
      {'CONTENT_TYPE' => 'application/json'}
    )

    # delete successful
    assert_equal(204, last_response.status)

    # make sure it's really gone
    get("/shortened-urls/#{resp1[:shortName]}")
    assert_equal(400, last_response.status)
  end

  def test_delete_with_incorrect_secret
    full_url = 'http://some-long-url.com'

    # create a new short url
    resp1 = shorten(full_url)

    # delete it
    good_secret = resp1[:ownersSecret]
    bad_secret = good_secret.gsub(/./, 'a')  
    delete(
      "/shortened-urls/#{resp1[:shortName]}",
      {owners_secret: bad_secret},
      {'CONTENT_TYPE' => 'application/json'}
    )

    # delete successful
    assert_equal(403, last_response.status)
  end
end
