# Kriterion

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kriterion'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kriterion

## Usage

To create an example instance. Build and run the containers:

```shell
docker-compose up
```

Populate them

```shell
bundle exec ruby spec/populate_queue.rb http://localhost:8888
```

View the API: http://localhost:4567/reports

## Development

This project requires MongoDB and RestMQ to be up and working. You can run them up manually using the commands below, or run `docker-compose up` to spin up everything.

To populate the queue with example reports, run `bundle exec ruby spec/populate_queue.rb http://localhost:8888`

### Docker Containers

#### `kriterion_worker`

**Building:** `docker build -t kriterion_worker .`

**Running:** `docker run -t kriterion_worker`

#### `mongo`

**Building:** This comes from [DockerHub](https://hub.docker.com/_/mongo/)

**Running:** `docker run -p 27017:27017 mongo`

#### `restmq`

**Building:** This comes from [DockerHub](https://hub.docker.com/r/pablozaiden/restmq/)

**Running:** `docker run --rm  -p 6379:6379 -p 8888:8888 pablozaiden/restmq`


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/kriterion.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
