module LogParser
  class Client
    #
    # = Class
    #
    # Filter lines from the log file by chaining methods together:
    #
    #   log = LogParser::Client.new('some.log')
    #   log.errors.by_message('authentication failed').since(1.day.ago)
    #   #=> ["[2014-11-13T23:12:14-07:00] ERROR [page_id 95239] Authentication failed with token ..."]
    #

    attr_accessor :file, :line_pattern
    attr_writer :lines

    #
    # @param [String|Pathname] log name of the file in 'log' directory or a Pathname object
    # @param [Hash] options optional parameters
    # @option :line_items is an array of LineItem objects
    # @option :line_pattern a custom pattern to use for matching lines
    #
    def initialize(log = '', options = {})
      @file = log.is_a?(String) ? LogParser.path_for(log) : log
      @lines = options[:line_items]
      @line_pattern = options.fetch(:line_pattern, LogParser.line_pattern)
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

    def since(timestamp)
      items = lines.select { |line| DateTime.parse(line.timestamp) > timestamp }
      copy_self(items)
    end

    def by_message(pattern_or_text)
      pattern = pattern_or_text.is_a?(Regexp) ? pattern_or_text : Regexp.new(pattern_or_text, Regexp::IGNORECASE)
      items = lines.select { |line| line.message =~ pattern }
      copy_self(items)
    end

    def by_prefix(name)
      items = lines.select { |line| line.prefix == name }
      copy_self(items)
    end

    def by_type(name)
      items = lines.select { |line| line.type == name }
      copy_self(items)
    end

    #
    # Non-chainable Helpers
    #

    def prefixes
      items = Set.new
      lines.each { |line| items << line.prefix }
      items.to_a.compact
    end

    def uniq
      lines.uniq(&:full_message)
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

    alias length count

    def sort
      lines.sort
    end

    #
    # Default overrides
    #

    def to_s
      Array(@lines).map(&:to_s).to_s
    end

    alias inspect to_s

    #
    # Private
    #

    def copy_self(items)
      copy = clone
      copy.lines = items
      copy
    end

    def scan
      line_items = []
      File.open(file) do |f|
        line = nil
        begin
          line = f.gets
          line_items << LineItem.new($1, $3, $5, $6) if line =~ @line_pattern
        end while line
      end
      line_items
    end

    def lines
      @lines ||= scan
    end

    alias to_a lines
  end

end
