module Regex
  VERSION = "1.2.0"

  # Shortcut to create a new Regex::Extractor instance.
  def self.new(io, options={})
    Extractor.new(io, options)
  end
end

require 'regex/templates'
require 'regex/extractor'
require 'regex/replacer'
require 'regex/command'

