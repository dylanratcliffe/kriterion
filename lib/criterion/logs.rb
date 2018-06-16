require 'logger'

module Kriterion::Logs
  DEBUG = ::Logger::DEBUG

  def logger
    unless $logger
      $logger       = ::Logger.new(STDOUT)
      $logger.level = ::Logger::WARN
    end
    $logger
  end
end
