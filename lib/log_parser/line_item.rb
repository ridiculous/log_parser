module LogParser
  class LineItem < BasicObject
    attr_reader :timestamp, :type, :prefix, :message

    def initialize(timestamp, type, prefix, message)
      @timestamp, @type, @prefix, @message = timestamp, type, prefix, message
    end

    def to_s
      s = "[#{timestamp}] "
      s << "#{type}: " if type
      s << "[#{prefix}] " if prefix
      s << "#{message}"
      s
    end

    alias inspect to_s

    def full_message
      prefix ? "[#{prefix}] #{message}" : message
    end

    def <=>(other)
      timestamp <=> other.timestamp
    end
  end
end
