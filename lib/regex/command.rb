require 'regex'

class Regex

  # Commandline interface.
  #
  class Command

    #
    attr :file

    #
    attr :options

    #
    def self.main(*argv)
      new(*argv).main
    end

    # New Command.
    def initialize(*argv)
      parser.parse!(argv)
      unless @options[:template]
        @options[:pattern] = argv.shift
      end
      @file = argv.shift
      unless @file && File.file?(@file)
        puts "No such file -- '#{file}'."
        exit 1
      end
    end

    # OptionParser instance.
    def parser
      require 'optparse'
      @options = {}
      OptionParser.new do |opt|
        opt.on('--template', '-t NAME', "") do |name|
          @options[:template] = name
        end

        opt.on('--index', '-n INT', "match index") do |int|
          @options[:index] = int.to_i
        end

        opt.on('--insensitive', '-i', "case insensitive") do
          @options[:insensitive] = true
        end

        opt.on('--unxml', '-x', "") do
          @options[:unxml] = true
        end

        opt.on('--repeat', '-r', "") do
          @options[:repeat] = true
        end

        opt.on_tail('--help') do
          puts opt
          exit 0
        end
      end
    end

    #
    def extraction
      Regex.load(@file, options)
    end

    # Extract and display.
    def main
      puts extraction
    end

  end

end

