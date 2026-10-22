FROM node:22.23.4-bookworm-slim AS node-runtime

FROM ruby:3.3

RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=node-runtime /usr/local/bin/node /usr/local/bin/node
RUN node --version

WORKDIR /docker/app

RUN gem install bundler -v 2.5.23

COPY Gemfile* ./

RUN bundle install

ADD . /docker/app

ARG DEFAULT_PORT 4000

EXPOSE ${DEFAULT_PORT}

CMD ["rails", "server", "-b", "0.0.0.0"]
