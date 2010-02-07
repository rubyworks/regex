require 'proutils/xact/extractor.rb'
require 'test/unit'

class ExtractorTest < Test::Unit::TestCase

  def knife
    @knife ||= ProUtils::Extractor.new <<-HERE
      This is a "test".
      =begin
      Word
      =end
    HERE
  end

  def test_extract_block
    text, line = *knife.extract_block('=begin', '=end')
    assert_equal('Word', text.strip)
    assert_equal(1, line)
  end

  def test_extract_pattern
    text, line = *knife.extract_pattern(/\"(.*?)\"/)
    assert_equal('test', text)
    assert_equal(0, line)
  end

=begin
  def build_pattern_block(block, code)
    knife.pattern_block(block).match(code)
  end

  # Usual case.

  def test_pattern_block
    assert_equal "require 'foo'\nfoo", build_pattern_block('test', "=begin test\nrequire 'foo'\nfoo\n=end")[1]
  end

  # Some tests for when the block is empty ('') -- should it act as a wildcard and match *any* block,
  # or should Exacto::Command#initialize complain about that.

  def test_pattern_block_no_handle
    assert_equal "require 'foo'\nfoo", build_pattern_block('', "=begin\nrequire 'foo'\nfoo\n=end")[1]
  end

  def test_pattern_block_no_handle_given
    assert_equal "require 'foo'\nfoo", build_pattern_block('', "=begin test\nrequire 'foo'\nfoo\n=end")[1]
  end

  # Yes, I know, as a side-effect of this regexp change, it will also match some invalid "blocks", like =beginblah. But that
  # seems like a nonissue, given that the Ruby parser would reject that syntax anyway.

  def test_pattern_block_side_effects
    assert_equal "require 'foo'\nfoo", build_pattern_block('', "=beginblah\nrequire 'foo'\nfoo\n=end")[1]
  end
=end

end

