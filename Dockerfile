FROM ruby:2.5

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /app

COPY . .
RUN bundle install -j 8

ENV mongo_database kriterion
ENV mongo_hostname mongodb
ENV mongo_port 27017
ENV queue reports
ENV uri http://restmq:8888

ENTRYPOINT ["bundle", "exec", "kriterion"]
