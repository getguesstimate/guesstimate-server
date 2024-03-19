# README

[ ![Codeship Status for getguesstimate/guesstimate-server](https://codeship.com/projects/91bb1160-c8b7-0133-8173-1ac51750ca4c/status?branch=master)](https://codeship.com/projects/139418)

## Development

Development should be done with Docker, which standardizes the environment that's used to run this project.

If you can't or don't want to use Docker, you can read through `compose.yaml` and `Dockerfile` configs and adapt them for your own development environment.

### Docker

1. Install `docker` its `docker compose` plugin. If you're on macOS, either Docker Desktop or Colima are good options.
2. Run `docker compose build`.
3. Run `docker compose up`. By default, it will expose the server on http://localhost:4000. If you want to use another port, update `compose.yaml` config accordingly.
4. Run `docker compose run --rm web rails db:prepare` to prepare the database.

To see if things are working, try running the tests: `docker compose run --rm web bundle exec rspec`

## Deployment

API for the main Guesstimate instance, https://api.getguesstimate.com, is deployed on QURI Kubernetes cluster.
