module Regex
  VERSION = "1.1.0"

  # Shortcut to create a new Regex::Extractor instance.
  def self.new(io, options={})
    Extractor.new(io, options)
  end
end

require 'regex/command'
require 'regex/extrator'
require 'regex/templates'

