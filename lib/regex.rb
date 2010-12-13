module Regex
  # Access to PACAKGE metadata.
  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load(File.new(File.dirname(__FILE__) + '/regex.yml'))
    )
  end

  # Need VRESION? You got it.
  def self.const_missing(name)
    metadata[name.to_s.downcase] || super(name)
  end

  # TODO: This is only here to support broken Ruby 1.8.x.
  VERSION = metadata['version']

  # Shortcut to create a new Regex::Extractor instance.
  def self.new(*io)
    Extractor.new(*io)
  end
end

require 'regex/templates'
require 'regex/extractor'
require 'regex/replacer'
require 'regex/command'

