require "log_parser/version"

class LogParser
  #
  # = Class
  #
  # Filter lines from the log file by chaining methods together:
  #
  #   log = LogParser.new('open_table.log')
  #   log.errors.by_message('authentication failed').since(1.day.ago)
  #   #=> ["[2014-11-13T23:12:14-07:00] ERROR [page_id 95239] Authentication failed with token ..."]
  #

  LINE_PATTERN = %r{
                    \[(\d+-\d+-\d+T\d+:\d+:\d+-\d+:\d+)\] # timestamp
                    (\s(\w+):)?                           # type of message (ERROR, WARNING, INFO)
                    (\s\[(.+)\])?                         # prefix (introduced by log.rb)
                    \s(.+)$                               # message body
                  }x

  attr_reader :file_path
  attr_writer :lines

  # @param log [String|Pathname] The file name in the log directory or a pathname to a log file
  # @param line_items [Array] (optional) An array of LineItems
  def initialize(log = '', line_items = [])
    @file_path = log.is_a?(String) ? Rails.root.join('log', log) : log
    @lines = line_items
  end

  #
  # Chainable
  #

  def errors
    by_type('ERROR')
  end

  def warnings
    by_type('WARNING')
  end

  def infos
    by_type('INFO')
  end

  def by_message(text)
    chain do |items|
      for line in lines
        items << line if line.message =~ Regexp.new(text, Regexp::IGNORECASE)
      end
    end
  end

  def since(timestamp)
    chain do |items|
      for line in lines
        items << line if DateTime.parse(line.timestamp) > timestamp
      end
    end
  end

  def by_prefix(name)
    chain do |items|
      for line in lines
        items << line if line.prefix == name
      end
    end
  end

  def by_type(name)
    chain do |items|
      for line in lines
        items << line if line.type == name
      end
    end
  end

  #
  # Helpers
  #

  def prefixes
    items = Set.new
    lines.each { |line| items << line.prefix }
    items.to_a.compact
  end

  def timestamps
    lines.map(&:timestamp)
  end

  def messages
    lines.map(&:message)
  end

  def strings
    lines.map(&:to_s)
  end

  def count
    lines.count
  end

  def uniq
    lines.uniq { |line| line.full_message }
  end

  def to_s
    Array(@lines).map(&:to_s).to_s
  end

  alias inspect to_s

  #
  # Private
  #

  def scan
    line_items = []
    File.open(file_path) do |f|
      while line = f.gets
        line_items << LineItem.new($1, $3, $5, $6) if line =~ LINE_PATTERN
      end
    end
    line_items
  end

  def chain
    items = []
    yield items
    self.class.new(file_path, items)
  end

  def lines
    @lines.presence || scan
  end

  alias to_a lines

  class LineItem < Struct.new(:timestamp, :type, :prefix, :message)
    def to_s
      s = "[#{timestamp}] "
      s << "#{type}: " if type
      s << "[#{prefix}] " if prefix
      s << "#{message}"
      s
    end

    def full_message
      prefix ? "[#{prefix}] #{message}" : message
    end

    def <=>(other)
      timestamp <=> other.timestamp
    end
  end
end
