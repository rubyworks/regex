require 'fileutils'
require 'open-uri'
require 'regex/string'

module Regex

  # Supports [:name:] notation for subsitution of built-in templates.
  class Extractor

    # When the regular expression return multiple groups,
    # each is divided by the group deliminator.
    # This is the default value.
    DELIMINATOR_GROUP  = 29.chr + "\n"

    # When using repeat mode, each match is divided by
    # the record deliminator. This is the default value.
    DELIMINATOR_RECORD = 30.chr + "\n"

    #
    def self.input_cache(input)
      @input_cache ||= {}
      @input_cache[input] ||= (
        case input
        when String
          input
        else
          input.read
        end
      )
    end

    # List of IO objects or Strings to search.
    attr_accessor :io

    # Remove XML tags from search. (NOT CURRENTLY SUPPORTED)
    attr_accessor :unxml

    # Regular expression.
    attr_accessor :pattern

    # Select built-in regular expression by name.
    attr_accessor :template

    # Is a recusive serach?
    attr_accessor :recursive

    # Index of expression return.
    attr_accessor :index

    # Multiline match.
    attr_accessor :multiline

    # Ignore case.
    attr_accessor :insensitive

    # Escape expression.
    attr_accessor :escape

    # Repeat Match (global).
    attr_accessor :repeat

    # Output format.
    attr_accessor :format

    # Provide detailed output.
    attr_accessor :detail

    # Use ANSI codes in output?
    attr_accessor :ansi

    # Use ANSI codes in output?
    def ansi? ; @ansi ; end

    # New extractor.
    def initialize(*io)
      options = Hash === io.last ? io.pop : {}

      @io   = io
      @ansi = true

      options.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #
    def inspect
      "#{self.class.name}"
    end

    #--
    # TODO: unxml is too primative, use real xml parser like nokogiri
    #++
    #def text
    #  @text ||= (
    #    if unxml
    #      raw.gsub!(/\<(.*?)\>/, '')
    #    else
    #      @raw
    #    end
    #  )
    #end

    #
    def regex
      @regex ||= (
        if template
          Templates.const_get(template.upcase)
        else
          case pattern
          when Regexp
            pattern
          when String
            flags = 0
            flags + Regexp::MULTILINE  if multiline
            flags + Regexp::IGNORECASE if insensitive
            if escape
              Regexp.new(Regexp.escape(pattern), flags)
            else
              pat = substitute_templates(pattern)
              Regexp.new(pat, flags)
            end
          end
        end
      )
    end

    #
    def substitute_templates(pattern)
      pat = pattern
      Templates.list.each do |name|
        if pat.include?("[:#{name}:]")
          pat = pat.gsub(/(?!:\\)\[\:#{name}\:\]/, Templates[name].to_s)
        end
      end
      pat
    end

    #
    def to_s(format=nil)
      case format
      when :yaml
        to_s_yaml
      when :json
        to_s_json
      else
        if detail
          output_detailed_text
        else
          output_text
        end
      end
    end

    #
    def to_s_yaml
      require 'yaml'
      if detail
        matches_by_path.to_yaml
      else
        structure.to_yaml
      end
    end

    #
    def to_s_json
      begin
        require 'json'
      rescue LoadError
        require 'json_pure' 
      end
      if detail
        matches_by_path.to_json
      else
        structure.to_json
      end
    end

    #
    def output_text
      out = structure
      if repeat
        out = out.map{ |m| m.join(deliminator_group) }
        out = out.join(deliminator_record) #.chomp("\n") + "\n"
      else
        out = out.join(deliminator_group) #.chomp("\n") + "\n"
      end
      out
    end

    # Detailed text output.
    def output_detailed_text
      if repeat
        count  = 0
        string = []
        mapping.each do |input, matches|
          path = (File === input ? input.path : "(io #{input.object_id})")
          string << ""
          string << bold(path)
          matches.each do |match|
            string << formatted_match(input, match)
            count += 1
          end
        end
        string.join("\n") + "\n"
        string << "\n(#{count} matches)"
      else
        string = []
        match  = scan.first
        input  = match.input
        path   = (File === input ? input.path : "(io #{input.object_id})")
        string << ""
        string << bold(path)
        string << formatted_match(input, match)
        string.join("\n")
        string << "" #"\n1 match"
      end
    end

    #
    def formatted_match(input, match)
      string = []
      path = (File === input ? input.path : "(io #{input.object_id})")
      part, char, line = match.info(0)
      if index
        part, char, line = match.info(index)
        string << "%s %s %s" % [line, char, part.inspect]
      else
        string << bold("%s %s %s" % [line, char, part.inspect])
        if match.size > 0
          (1...match.size).each do |i|
            part, char, line = match.info(i)
            string << "#{i}. %s %s %s" % [line, char, part.inspect]
          end
        end
      end
      string.join("\n")
    end

    #
    def matches_by_path
      r = Hash.new{ |h,k| h[k] = [] }
      h = Hash.new{ |h,k| h[k] = [] }
      scan.each do |match|
        h[match.input] << match
      end
      h.each do |input, matches|
        path = (File === input ? input.path : "(io #{input.object_id})")
        if index
          matches.each do |match|
            r[path] << match.breakdown[index]
          end
        else
          matches.each do |match|
            r[path] << match.breakdown
          end
        end
      end
      r
    end

    # Structure the matchdata according to specified options.
    def structure
      repeat ? structure_repeat : structure_single
    end

    # Structure the matchdata for single match.
    def structure_single
      structure_repeat.first
    end

    # Structure the matchdata for repeat matches.
    def structure_repeat
      if index
        scan.map{ |match| [match[index]] } 
      else
        scan.map{ |match| match.size > 1 ? match[1..-1] : [match[0]] }
      end
    end

    # Scan inputs for matches.
    #
    # Return an associative Array of [input, matchdata].
    def scan
      list = []
      io.each do |input|
        # TODO: limit to text files, how?
        begin
          text = read(input)
          text.scan(regex) do
            list << Match.new(input, $~)
          end
        rescue => err
          warn(input.inspect + ' ' + err.to_s) if $VERBOSE
        end
      end
      list
    end

    #
    def mapping
      hash = Hash.new{ |h,k| h[k]=[] }
      scan.each do |match|
        hash[match.input] << match
      end
      hash
    end

    # TODO: unxml won't give corrent char counts.
    def read(input)
      Extractor.input_cache(input)
      #  if unxml
      #    txt.gsub(/\<(.*?)\>/, '')
      #  else
      #    txt
      #  end
    end

    # Return the line number of the +char+ position within +text+.
    def line_at(io, char)
      read(io)[0..char].count("\n") + 1
    end

    def deliminator_group
      DELIMINATOR_GROUP
    end

    def deliminator_record
      DELIMINATOR_RECORD
    end

    # Commandline Interface to Extractor.
    def self.cli(argv=ARGV)
      require 'optparse'
      format  = nil
      options = {}
      parser = OptionParser.new do |opt|
        opt.on('--template', '-t NAME', "select a built-in regular expression") do |name|
          options[:template] = name
        end
        opt.on('--search', '-s PATTERN', "search for regular expression") do |re|
          options[:pattern] = re
        end
        opt.on('--recursive', '-R', 'search recursively though subdirectories') do
          options[:recursive] = true
        end
        opt.on('--index', '-n INT', "return a specific match index") do |int|
          options[:index] = int.to_i
        end
        opt.on('--insensitive', '-i', "case insensitive matching") do
          options[:insensitive] = true
        end
        opt.on('--multiline', '-m', "multiline matching") do
          options[:multiline] = true
        end
        #opt.on('--unxml', '-x', "ignore XML/HTML tags") do
        #  options[:unxml] = true
        #end
        opt.on('--global', '-g', "find all matching occurances") do
          options[:repeat] = true
        end
        opt.on('--yaml', '-y', "output in YAML format") do
          format = :yaml
        end
        opt.on('--json', '-j', "output in JSON format") do
          format = :json
        end
        opt.on('--detail', '-d', "provide match details") do
          options[:detail] = :json
        end
        opt.on('--[no-]ansi', "toggle ansi color") do |val|
          options[:ansi] = val
        end
        opt.on_tail('--debug', 'run in debug mode') do
          $DEBUG = true
        end
        opt.on_tail('--help', '-h', "display this lovely help message") do
          puts opt
          exit 0
        end
      end
      parser.parse!(argv)

      unless options[:pattern] or options[:template]
        re = argv.shift
        case re
        when /^\/(.*?)\/(\w*?)$/
          options[:pattern] = $1
          $2.split(//).each do |c|
            case c
            when 'e' then options[:escape] = true
            when 'g' then options[:repeat] = true
            when 'i' then options[:insensitive] = true
            end
          end
        else
          options[:template] = re
        end
      end

      files = []
      argv.each do |file|
        if File.directory?(file)
          if options[:recursive]
            rec_files = Dir[File.join(file, '**')].reject{ |d| File.directory?(d) }
            files.concat(rec_files)
          end
        elsif File.file?(file)
          files << file
        else
          $stderr.puts "Not a file -- '#{file}'."
          exit 1
        end
      end

      if files.empty?
        args = [ARGF]
      else
        args = files.map{ |f| open(f) } #File.new(f) }
      end

      args << options

      extract = new(*args)

      puts extract.to_s(format)
    end

    #
    def bold(str)
      if ansi?
        "\e[1m" + str + "\e[0m"
      else
        string
      end
    end


    #
    class Match
      attr :input
      attr :match

      # match - Instance of MatchData
      #
      def initialize(input, match)
        @input = input
        @match = match
      end

      #
      def [](i)
        @match[i]
      end

      #
      def size
        @match.size
      end

      #
      def breakdown
        m = []
        range = (0...match.size)
        range.each do |i|
          char = match.offset(i)[0]
          line = line_at(char)
          part = match[i]
          m << {'index'=>i, 'line'=>line, 'char'=>char, 'text'=>part}
        end
        m
      end

      #
      def info(index)
        text = match[index]
        char = match.offset(index)[0]
        line = line_at(char)
        return text, char, line
      end

      # Return the line number of the +char+ position within +text+.
      def line_at(char)
        return nil unless char
        text[0..char].count("\n") + 1
      end

      #
      def text
        Extractor.input_cache(input)
      end

    end


  end

end

