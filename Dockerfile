FROM ruby:2.7.7

RUN apt update && apt install -y nodejs

WORKDIR /docker/app

RUN gem install bundler -v 2.4.22

COPY Gemfile* ./

RUN bundle install

ADD . /docker/app

ARG DEFAULT_PORT 4000

EXPOSE ${DEFAULT_PORT}

CMD ["rails", "server", "-b", "0.0.0.0"]
