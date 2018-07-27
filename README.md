# Kriterion

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/kriterion`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

TODO: Write usage instructions here

## Development

This project requires MongoDB and RestMQ to be up and working. You can run them up manually using the commands below, or run `docker-compose up` to spin up everything.

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
