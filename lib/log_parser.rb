require 'date'
require 'pathname'

require 'log_parser/version'
require 'log_parser/configuration'
require 'log_parser/line_item'
require 'log_parser/client'

module LogParser
  extend self

  LINE_PATTERN = %r{
                    \[(\d+-\d+-\d+T\d+:\d+:\d+-\d+:\d+)\] # timestamp
                    (\s(\w+):)?                           # type of message (ERROR, WARNING, INFO)
                    (\s\[(.+)\])?                         # prefix (introduced by log.rb)
                    \s(.+)$                               # message body
                  }x

  def path_for(file)
    Pathname.new(File.join(Dir.pwd, 'log', file))
  end

  def configure
    yield config
  end

  def config
    @config ||= Configuration.new
  end

  def reset_config
    @config = nil
  end

  def line_pattern
    config.line_pattern || LINE_PATTERN
  end
end
