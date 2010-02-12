require 'regex'

class Regex

  # Commandline interface.
  #
  class Command

    #
    attr :file

    #
    attr :format

    #
    attr :options

    #
    def self.main(*argv)
      new(*argv).main
    end

    # New Command.
    def initialize(*argv)
      @file    = nil
      @format  = nil
      @options = {}
      parse(*argv)
    end

    #
    def parse(*argv)
      parser.parse!(argv)
      unless @options[:template]
        @options[:pattern] = argv.shift
      end
      @file = argv.shift
      if @file
        unless File.file?(@file)
          puts "No such file -- '#{file}'."
          exit 1
        end
      end
    end

    # OptionParser instance.
    def parser
      require 'optparse'
      @options = {}
      OptionParser.new do |opt|
        opt.on('--template', '-t NAME', "select a built-in regular expression") do |name|
          @options[:template] = name
        end

        opt.on('--index', '-n INT', "return a specific match index") do |int|
          @options[:index] = int.to_i
        end

        opt.on('--insensitive', '-i', "case insensitive matching") do
          @options[:insensitive] = true
        end

        opt.on('--unxml', '-x', "ignore XML/HTML tags") do
          @options[:unxml] = true
        end

        opt.on('--repeat', '-r', "find all matching occurances") do
          @options[:repeat] = true
        end

        opt.on('--yaml', '-y', "output in YAML format") do
          @format = :yaml
        end

        opt.on('--json', '-j', "output in JSON format") do
          @format = :json
        end

        opt.on_tail('--help', '-h', "display this lovely help message") do
          puts opt
          exit 0
        end
      end
    end

    #
    def extraction
      target = file ? File.new(file) : ARGF
      Regex.new(target, options)
    end

    # Extract and display.
    def main
      begin
        puts extraction.to_s(@format)
      rescue => error
        if $DEBUG
          raise error
        else
          abort error.to_s
        end
      end
    end

  end

end

