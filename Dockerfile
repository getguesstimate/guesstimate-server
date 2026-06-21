FROM ruby:3.3

RUN apt update && apt install -y nodejs libpq-dev

WORKDIR /docker/app

RUN gem install bundler -v 2.5.23

COPY Gemfile* ./

RUN bundle install

ADD . /docker/app

ARG DEFAULT_PORT 4000

EXPOSE ${DEFAULT_PORT}

CMD ["rails", "server", "-b", "0.0.0.0"]
