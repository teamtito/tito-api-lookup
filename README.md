# Tito API Lookup

## What?

Sometimes you want to be able to let folks do something with data in Tito without giving them full access to Tito. A simple app like this lets you pull from the Tito API, process the data, and output it to someone.

## Get started

`bundle install`

## Run in development

`cp .env-sample .env`

In `.env`:

- Set your Tito event
- Set your secret key in `.env`
- Set a random shared secret

`bundle exec puma`

Visit https://localhost:9292/lookup?q=XYZ&shared_secret=abc to look up against your event.

## Deploy to Heroku

- Visit https://localhost:9292
- Hit "Deploy to Heroku"

## Usage

`GET /lookup?q=< reference >&shared_secret=< your secret >`

If a ticket with that reference matches, you'll get:

```json
{ "valid": true, "name": "Joe Bloggs" }
```

If it doesn't match, you'll get:

```json
{ "valid": false }
```

## Development

If you want to make changes, you can use rerun to load changes automatically:

`bundle exec rerun puma`
