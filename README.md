# LogParser

A simple class for searching through a log. By default, LogParser knows how to read Unicorn production logs and the default logging pattern for Ruby's Logger library. A custom pattern can be passed, or the defaults can be found in [log_parser.rb](https://github.com/ridiculous/log_parser/blob/master/lib/log_parser.rb#L12)

## Installation

Add this line to your application's Gemfile:

    gem 'log_parser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install log_parser

## Usage

The class offers a some methods for scanning through a log `by_message(msg)`, `erors`, `warnings`, `since(datetime)` and `uniq`.
These methods can be chained together to refine your search. For example:

```Ruby
log = LogParser::Client.new('some.log', line_pattern: LogParser::LOGGER_PATTERN)
log.errors.by_message('authentication failed').since(1.day.ago)
#=> ["[2014-11-13T23:12:14-07:00] ERROR [page_id 95239] Authentication failed with token ..."]
```
	
## Contributing

1. Fork it ( https://github.com/[my-github-username]/log_parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
