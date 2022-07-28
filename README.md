# README

[ ![Codeship Status for getguesstimate/guesstimate-server](https://codeship.com/projects/91bb1160-c8b7-0133-8173-1ac51750ca4c/status?branch=master)](https://codeship.com/projects/139418)

## Getting Started

### Ubuntu

These instructions were tested on Ubuntu 21.10.

0. Set up a Ruby version manager, such as [Rbenv](https://github.com/rbenv/rbenv), and install the version of Ruby specified in [`.ruby-version`](https://github.com/getguesstimate/guesstimate-server/blob/master/.ruby-version).
1. Install [`libpq`](https://www.postgresql.org/docs/9.5/libpq.html): `sudo apt install libpq-dev`
2. [Dependency `racc` will fail without `ubuntu-dev-tools`](https://stackoverflow.com/questions/27768420/gem-installation-error-you-have-to-install-development-tools-first-windows): `sudo apt install ubuntu-dev-tools`
3. Rails expects a JavaScript runtime, so `sudo apt install nodejs`
4. Inside the application root directory, install gems: `bundle install`
5. Install PostgreSQL (note that the version may not match the production version): `sudo apt install postgresql`
6. Start PostgreSQL: `sudo service postgresql start`
7. Start a PostgreSQL console: `sudo -upostgres psql`
    1. Create the `guesstimate-api` user: `create user "guesstimate-api" with password 'password';`
    2. Allow the user to create databases: `alter user "guesstimate-api" createdb;`
8. Create the necessary databases and run migrations: `bundle exec rails db:setup`

To see if things are working, try running the tests: `bundle exec rspec`

## Deployment

prod is pegged to branch `production` within heroku.
