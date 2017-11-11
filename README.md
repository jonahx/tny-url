export TEST_DATABASE_URL=postgres://jg:888888@localhost/conjur
rerun --no-notify 'bundle exec thin start'

Like to be able to pull out business transactions and make them testable 
outside the framework

should a deleted `short_name` be reusable?
  - more complex constraint
  - remove constraint and do logic in the repo

# Unlikely collisions: 62^6x 56800235584
#   Could: Put hash logic in a db trigger
#          Do a transaction where you check first then insert
#
# Mount API at api/ and the webapp at the root
# Make them proper sinatra apps


repo has a hard dependency on `DB` and `Constants.full_url`.  Could be passed in,
and you create configured instances of repo

make db work
add on the other endpoints
make some end to end tests

Note: duplication between `owners_secret` and `short_name`.  Could use Class.new to avoid repeated code.

For automatic reloading during development:

```
rerun --no-notify 'bundle exec thin start'
```
