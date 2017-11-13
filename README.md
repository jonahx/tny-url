# Demo

Frontend demo available here: https://tny-url.herokuapp.com

It's on heroku's free tier, so your initial request may have a 5 or so second delay.

The application has two parts: an API and a client frontend which uses that API.  They are separate sinatra apps, both automatically deployed to appropriate urls via `Rack::URLMap` inside `config.ru`:

```ruby
run Rack::URLMap.new(
  '/' => FrontendApp.new,
  "/api" => ApiApp.new
)
```

I should note that the frontend UX is not what I'd do if there were a "real" URL shortener -- I've done enough usability testing to know a substantial number of people would be confused.  But I thought I'd have a bit of fun with it.

# Installation

Requirements:

- **A web server**.  Simply cloning the project and pushing it to a newly created heroku app will handle this part.
- **A postgres database**. Put its full connection string in the environment variable `DATABASE_URL`.  Again, on heroku, this will be populated automatically when attaching a postgres addon with, eg, `heroku addons:create heroku-postgresql:hobby-dev`.  Additionally, the application will look for the environment variable `TEST_DATABASE_URL` instead during development.  That is, if `ENV['RACK_ENV']` has a value other than `production`, as it typically does when developing locally.
- **A environment variable named `BASE_URL`**.  Eg, in the demo application, this value is `https://tny-url.herokuapp.com`.  Heroku will not automatically create this.

After creating the database, you'll need to initialize it with:

```
sequel -m migrations postgres://host/database
```

# API

The API expects JSON bodies and returns JSON responses.  Successful responses that return data will have the form:

```
{"status": "success", "data": "some data"}
```

Client errors, such as validation, will return:

```
{"status": "fail", "message": "Error description"}
```

While true unexpected server errors will return:

```
{"status": "error", "message": "Error description"}
```

## API endpoints

- `POST /shortened-urls`: Required body parameter `full_url` and optional body parameter `short_name` (when a vanity `short_name` isn't provided, a random 6 character string is generated).  Successful return data looks like:
```
{
  fullUrl: "http://www.sinatrarb.com/intro.html",
  shortUrl: "https://tny-url.herokuapp.com/duDGxI",
  shortName: "duDGxI",
  ownersSecret: "J1r9fSU88MKpMLENPuZXt8hvdvGdHUM2"
}
```
- `GET /shortened-urls/:short_name`: Successful response looks like:
```
{
  fullUrl: "http://www.sinatrarb.com/intro.html",
  shortUrl: "https://tny-url.herokuapp.com/duDGxI"
}
```
- `DELETE /shortened-urls/:short-name` Required body parameter `owners_secret`, returned by the POST.  Successful deletions return 204.

# Developer Notes

## Architecture

For such a small set of features, breaking things apart in the way I have is certainly not necessary.  I could have easily thrown the validation and database interaction all into the route handlers, and had a single file for everything.

Even on small projects, though, pushing business logic and validation into stateless domain objects (everything in the `domain` directory in this case) can clarify concepts and improve readability.

Some notable benefits:

1. **Clear and comprehensive names**.  Everything from the individual errors to the secret hash needed for deleting your own shortened urls is captured as an explicit concept and named.  This idea of "making implicit concepts explicit" is, imo, the most useful idea of [Domain Driven Design](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215).

2. **Clear high-level use cases** Currently, our use-cases are creating a short url, looking up a url by its short name, and deleting a shortened a url.  The complete high-level logic -- the happy path as well as all the sad paths -- is visible in a handful lines under each route.  The lower-level details are pushed into the appropriate places: the validation logic is pushed into the domain objects, which are essentially type definitions, and all database specific implementation concerns are hidden in the repository, which takes in and returns domain objects.

3. **Decoupling application logic from the web framework**.  Sinatra is being used here purely as a delivery mechanism: Its job is to collect user-submitted information into a params hash, and to turn our application objects back into the appropriate http responses (http response codes and json, in this case).  

4. **Fast, isolated tests** Because the business logic is contained in plain ruby objects, even suites of hundreds of tests can execute instantly, and there's no need to run tests through a web server or mock server.  Currently, the use-case logic exists inside the routes (and would need to Rack::Test or similar), but if needed even that could be trivially extracted into service objects and tested independently of the "web application" context in which they're currently being used.  But doing so at this point would be a premature optimization.

## Cut corners

Currently the default shortcodes are randomly generated 6-character strings, including digits and both cases of letters.  This gives a total of `62^6 = 56800235584` possibilities, making collisions highly unlikely but technically possible in a massively scaled app.

This means a user could conceivably receive a "This short name is unavailable error" on a default code, which doesn't make sense.  

To solve this, you could query for each generated code before attempting the insert (with the query/insert combo inside a transaction), which would reduce the chance of a collision to very near zero (though still not zero -- that would require a full table lock).

## Possible TODO

- Frontend manage link page that uses allows owner to delete links using API's `DELETE` method.
- Add option for vanity short codes (again, API support for this already exists).  I think a good UX would be to allow an "edit" of the shortened url after it was created, which behind the scenes would simply create a new one.  This would allow us to keep the current "one paste and done" UX which is probably the most efficient for 90% of use cases.
- Link tracking


## Automatic reloading during API development

```
rerun --no-notify 'bundle exec thin start'
```
