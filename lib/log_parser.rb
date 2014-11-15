require 'date'

require 'log_parser/version'
require 'log_parser/line_item'
require 'log_parser/client'

module LogParser
  def self.path_for(file)
    Pathname.new(File.join(Dir.pwd, 'log', file))
  end
end
