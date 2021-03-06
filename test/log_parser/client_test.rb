require 'minitest/autorun'
require 'log_parser'

class LogParser::ClientTest < MiniTest::Unit::TestCase

  def setup
    @file = Pathname.new(File.expand_path(File.join('..', '..', 'fixtures', 'example.log'), __FILE__))
    @log = LogParser::Client.new(@file)
    @date = DateTime.parse('2014-11-13T23:12:12-07:00')
  end

  def test_initialize_with_string
    @log = LogParser::Client.new('test.log')
    assert_kind_of Pathname, @log.file
    assert_match %r{/log_parser/log/test.log}, @log.file.to_s
  end

  def test_initialize_with_pathname
    assert_kind_of Pathname, @log.file
    assert_equal @log.file.to_s, @file.to_s
    assert_equal File.exists?(@log.file), true
  end

  def test_errors
    errors = @log.errors.to_a
    assert_equal 1, errors.count
    assert_equal 'page_id 95239', errors.first.prefix
    assert_match /failed to save/i, errors.first.message
  end

  def test_warnings
    warnings = @log.warnings.to_a
    assert_equal 1, warnings.count
    assert_equal 'page_id 75645', warnings.first.prefix
    assert_match /failed to find page/i, warnings.first.message
  end

  def test_infos
    infos = @log.infos.to_a
    assert_equal 5, infos.count
    assert_equal 'page_id 24323', infos.first.prefix
    assert_match /Updating page/i, infos.first.message
  end

  def test_since
    lines = @log.since(DateTime.parse('2014-11-13T23:12:15-07:00')).to_a
    assert_equal 3, lines.count
    assert_equal '[page_id 95239] Updating page and reviews', lines.first.full_message
  end

  def test_by_message
    lines = @log.by_message('validation failed').to_a
    assert_equal 1, lines.count
    assert_equal %Q([2014-11-13T23:12:18-07:00] ERROR: [page_id 95239] Failed to save reviews! Validation failed: Text can't be blank),
      lines.first.to_s
  end

  def test_by_prefix
    lines = @log.by_prefix('page_id 24323').to_a
    assert_equal 3, lines.count
    assert_equal ['page_id 24323'], lines.map(&:prefix).uniq
  end

  def test_prefixes
    prefixes = @log.prefixes
    assert_equal 3, prefixes.count
    assert_equal ['page_id 24323', 'page_id 75645', 'page_id 95239'], prefixes
  end

  #
  # Chaining
  #

  def test_prefix_is_chainable
    prefix_lines = @log.by_prefix('foobar')
    assert_respond_to prefix_lines, :by_message
    assert_respond_to prefix_lines, :by_type
    assert_respond_to prefix_lines, :since
  end

  def test_filtering_by_chaining
    lines = @log.by_prefix('page_id 24323').by_message(/saved \d+ reviews/i).since(@date).uniq
    assert_equal 1, lines.count
    assert_equal '[page_id 24323] Saved 10 reviews', lines.first.full_message
  end

  def test_no_chain_mutation
    @log.by_prefix('page_id 24323').by_message(/saved \d+ reviews/i).since(@date).uniq
    assert_equal 7, @log.lines.count
  end
end
