# Tito API Lookup

## Get started

`bundle install`

## Run in development

`cp .env-sample .env`

- Set your Tito event in `.env`
- Set your secret key in `.env`

`bundle exec rerun "rackup"`

Visit https://localhost:9292/lookup?q=XYZ to look up against your event.

## Deploy to Heroku

- Visit https://localhost:9292
- Hit "Deploy to Heroku"
