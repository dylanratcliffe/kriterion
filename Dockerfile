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
ENV restmq_uri http://restmq:8888

CMD bundle exec kriterion worker --debug --uri $restmq_uri --mongo_database $mongo_database --mongo_hostname $mongo_hostname --mongo_port $mongo_port --queue $queue
