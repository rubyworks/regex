require 'stringio'
require 'optparse'

module Regex

  #
  class Replacer

    # Array of [search, replace] rules.
    attr_reader :rules

    # Is this a recursive search?
    attr_accessor :recursive

    # Make all patterns exact string matchers.
    attr_accessor :escape

    # Make all patterns global matchers.
    attr_accessor :global

    # Make all patterns case-insenstive matchers.
    attr_accessor :insensitive

    # Make all patterns multi-line matchers.
    attr_accessor :multiline

    # Make backups of files when they change.
    attr_accessor :backup

    # Interactive replacement.
    attr_accessor :interactive

    #
    def initialize(options={})
      @rules = []
      options.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #
    def rule(pattern, replacement)
      @rules << [re(pattern), replacement]
    end

    #
    def apply(*ios)
      ios.each do |io|
        original = (IO === io || StringIO === io ? io.read : io.to_s)
        generate = original.to_s
        rules.each do |(pattern, replacement)|
          begin
            if pattern.global
              generate = generate.gsub(pattern.to_re, replacement)
            else
              generate = generate.sub(pattern.to_re, replacement)
            end
          rescue => err
            warn(io.inspect + ' ' + err.to_s) if $VERBOSE
          end
        end
        if original != generate
          write(io, generate)
        end
      end
    end

    #
    # TODO: interactive mode needs to handle \1 style substitutions.
    def interactive_gsub(string, pattern, replacement)
      copy = string.dup
      string.scan(pattern) do |match|
        print "#{match} ? (Y/n)"
        case ask
        when 'y', 'Y', ''
          copy[$~.begin(0)..$~.end(0)] = replacement
        else
        end
      end
    end

    private

    # Parse pattern matcher.
    def re(pattern)
      Matcher.new(
        pattern,
        :global=>global,
        :escape=>escape,
        :multiline=>multiline,
        :insensitive=>insensitive
      )
    end

    #
    def write(io, text)
      case io
      when File
        if backup
          backup_file = io.path + '.bak'
          File.open(backup_file, 'w'){ |f| f << File.read(io.path) }
        end
        File.open(io.path, 'w'){ |w| w << text }
      when StringIO
        io.string = text
      when IO
        # TODO: How to handle general IO object?
        io.write(text)
      else
        io.replace(text)
      end
    end

    #
    def self.cli(argv=ARGV)
      searches = []
      replaces = []
      options = {}
      parser = OptionParser.new do |opt|
        opt.on('--search', '-s PATTERN', 'search portion of substitution') do |search|
          searches << search
        end
        opt.on('--template', '-t NAME', 'search for built-in regular expression') do |name|
          searches << "$#{name}"
        end
        opt.on('--replace', '-r STRING', 'replacement string of substitution') do |replace|
          replaces << replace
        end
        opt.on('--recursive', '-R', 'search recursively though subdirectories') do
          options[:recursive] = true
        end
        opt.on('--escape', '-e', 'make all patterns verbatim string matchers') do
          options[:escape] = true
        end
        opt.on('--insensitive', '-i', 'make all patterns case-insensitive matchers') do
          options[:insensitive] = true
        end
        #opt.on('--unxml', '-x', 'ignore XML/HTML tags') do
        #  options[:unxml] = true
        #end
        opt.on('--global', '-g', 'make all patterns global matchers') do
          options[:global] = true
        end
        opt.on('--multiline', '-m', 'make all patterns multi-line matchers') do
          options[:multiline] = true
        end
        opt.on('-b', '--backup', 'backup any files that are changed') do
          options[:backup] = true
        end
        opt.on('-i', '--interactive', 'interactive mode') do
          options[:interactive] = true
        end
         opt.on_tail('--debug', 'run in debug mode') do
          $DEBUG = true
        end
        opt.on_tail('--help', '-h', 'display this lovely help message') do
          puts opt
          exit 0
        end
      end
      parser.parse!(argv)

      files = []

      argv.each{ |file|
        raise "file does not exist -- #{file}" unless File.exist?(file)
        if File.directory?(file)
          if options[:recursive] 
            files.concat Dir[File.join(file, '**')].reject{ |d| File.directory?(d) }
          end
        else
          files << file
        end
      }

      targets = files.empty? ? [ARGF] : files.map{ |f| File.new(f) }

      unless searches.size == replaces.size
        raise "search replace mismatch -- #{searches.size} to #{replaces.size}"
      end
      rules = searches.zip(replaces)

      replacer = new(options)
      rules.each do |search, replace|
        replacer.rule(search, replace)
      end
      replacer.apply(*targets)
    end

    # Basically a Regex but handles a couple extra options.
    class Matcher

      #
      attr_accessor :global

      #
      attr_accessor :escape

      #
      attr_accessor :multiline

      #
      attr_accessor :insensitive

      #
      def initialize(pattern, options={})
        options.each do |k,v|
          __send__("#{k}=", v) if respond_to?("#{k}=")
        end
        @regexp = parse(pattern)
      end

      #
      def =~(string)
        @regexp =~ string
      end

      #
      def match(string)
        @regexp.match(string)
      end

      #
      def to_re
        @regexp
      end

      # Parse pattern matcher.
      def parse(pattern)
        case pattern
        when Regexp
          pattern
        when /^\$/
          Templates.const_get($'.upcase)
        when /^\/(.*?)\/(\w+)$/
          flags = []
          @global = true if $2.index('g')
          flags << Regexp::MULTILINE  if $2.index('m') or multiline
          flags << Regexp::IGNORECASE if $2.index('i') or insensitive
          if $2.index('e') or escape
            Regexp.new(Regexp.escape($1), *flags)
          else
            Regexp.new($1, *flags)
          end
        else
          flags = []
          flags << Regexp::MULTILINE  if multiline
          flags << Regexp::IGNORECASE if insensitive
          if escape
            Regexp.new(Regexp.escape(pattern), *flags)
          else
            Regexp.new(pattern, *flags)
          end
        end
      end

    end

  end

end
