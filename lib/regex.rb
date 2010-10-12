module Regex
  DIRECTORY = File.dirname(__FILE__)

  # Access to PACAKGE metadata.
  def self.package
    @package ||= (
      require 'yaml'
      YAML.load(File.new(DIRECTORY + '/regex/package.yml'))
    )
  end

  # Need VRESION? You got it.
  def self.const_missing(name)
    package[name.to_s.downcase] || super(name)
  end

  # Shortcut to create a new Regex::Extractor instance.
  def self.new(*io)
    Extractor.new(*io)
  end
end

require 'regex/templates'
require 'regex/extractor'
require 'regex/replacer'
require 'regex/command'

