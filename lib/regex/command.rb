require 'regex/extractor'
require 'regex/replacer'

module Regex

  # Commandline interface.
  def self.cli(*argv)
    if argv.include?('-r') or argv.include?('--replace')
      controller = Replacer
    else
      controller = Extractor
    end

    begin
      controller.cli(argv)
    rescue => error
      if $DEBUG
        raise error
        #puts error.backtrace.join("\n   ")
      else
        abort error.to_s
      end
    end
  end

end

