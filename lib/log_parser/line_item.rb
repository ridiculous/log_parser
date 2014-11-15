module LogParser
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
