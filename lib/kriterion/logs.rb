require 'logger'

module Kriterion::Logs
  DEBUG = ::Logger::DEBUG
  INFO  = ::Logger::INFO

  def logger
    unless $logger
      $logger       = ::Logger.new(STDOUT)
      $logger.level = ::Logger::INFO
    end
    $logger
  end
end
