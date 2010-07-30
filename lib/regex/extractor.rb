require 'fileutils'
require 'open-uri'
require 'regex/string'

module Regex

  #
  class Extractor

    # When the regular expression return multiple groups,
    # each is divided by the group deliminator.
    # This is the default value.
    DELIMINATOR_GROUP  = 29.chr + "\n"

    # When using repeat mode, each match is divided by
    # the record deliminator. This is the default value.
    DELIMINATOR_RECORD = 30.chr + "\n"

    #
    #attr_accessor :text

    # Remove XML tags from search.
    attr_accessor :unxml

    # Regular expression.
    attr_accessor :pattern

    # Select built-in regular expression by name.
    attr_accessor :template

    # Index of expression return.
    attr_accessor :index

    # Ignore case.
    attr_accessor :insensitive

    # Repeat Match.
    attr_accessor :repeat

    # Output format.
    attr_accessor :format

    # DEPRECATE: Not needed anymore.
    #def self.load(io, options={}, &block)
    #  new(io, options, &block)
    #end

    # New extractor.
    def initialize(io, options={})
      @raw = (String === io ? io : io.read)
      options.each do |k,v|
        __send__("#{k}=", v)
      end
      yield(self) if block_given?
    end

    # Read file.
    #def raw
    #  @raw ||= open(@file) # File.read(@file)
    #end

    #--
    # TODO: unxml is too primative, use real xml parser like nokogiri
    #++
    def text
      @text ||= (
        if unxml
          raw.gsub!(/\<(.*?)\>/, '')
        else
          @raw
        end
      )
    end

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
            flags = []
            flags << Regexp::MULTILINE
            flags << Regexp::IGNORECASE if insensitive
            Regexp.new(pattern, *flags)
          end
        end
      )
    end

    #
    def to_s(format=nil)
      case format
      when :yaml
        to_s_yaml
      when :json
        to_s_json
      else
        out = structure
        if repeat
          out = out.map{ |m| m.join(deliminator_group) }
          out = out.join(deliminator_record) #.chomp("\n") + "\n"
        else
          out = out.join(deliminator_group) #.chomp("\n") + "\n"
        end
        out
      end
    end

    #
    def to_s_yaml
      require 'yaml'
      structure.to_yaml
    end

    #
    def to_s_json
      begin
        require 'json'
      rescue LoadError
        require 'json_pure' 
      end
      structure.to_json
    end

    # Structure the matchdata according to specified options.
    def structure
      repeat ? structure_repeat : structure_single
    end

    # Structure the matchdata for single match.
    def structure_single
      md = extract
      if index
        [md[index]]
      elsif md.size > 1
        md[1..-1]
      else
        [md[0]]
      end
    end

    # Structure the matchdata for repeat matches.
    def structure_repeat
      out = extract
      if index
        out.map{ |md| [md[index]] }
      else
        out.map{ |md| md.size > 1 ? md[1..-1] : [md[0]] }
      end
    end

    # Extract match from source text.
    def extract
      if repeat
        extract_repeat
      else
        extract_single
      end
    end

    #
    #def extract_single
    #  out = []
    #  if md = matchdata
    #    if index
    #      out << md[index]
    #    elsif md.size > 1
    #      out = md[1..-1] #.join(deliminator_group)
    #    else
    #      out = md
    #    end
    #  end
    #  return out
    #end

    # Extract single match from source text.
    def extract_single
      md = regex.match(text)
      md ? md : []
    end

    #
    #def matchdata
    #  regex.match(text)
    #end

    #
    #def extract_repeat
    #  out = []
    #  text.scan(regex) do
    #    md = $~
    #    if index
    #      out << [md[index]]
    #    elsif md.size > 1
    #      out << md[1..-1] #.join(deliminator_group)
    #    else
    #      out << md
    #    end      
    #  end
    #  out #.join(deliminator_record)
    #end

    # Extract repeat matches from source text.
    def extract_repeat
      out = []
      text.scan(regex) do
        out << $~
      end
      out
    end

    def deliminator_group
      DELIMINATOR_GROUP
    end

    def deliminator_record
      DELIMINATOR_RECORD
    end

    # Commandline Interface to Extractor
    def self.cli(argv=ARGV)
      require 'optparse'
      options = {}
      parser = OptionParser.new do |opt|
        opt.on('--template', '-t NAME', "select a built-in regular expression") do |name|
          options[:template] = name
        end
        opt.on('--index', '-n INT', "return a specific match index") do |int|
          options[:index] = int.to_i
        end
        opt.on('--insensitive', '-i', "case insensitive matching") do
          options[:insensitive] = true
        end
        opt.on('--unxml', '-x', "ignore XML/HTML tags") do
          options[:unxml] = true
        end
        opt.on('--global', '-g', "find all matching occurances") do
          options[:repeat] = true
        end
        opt.on('--yaml', '-y', "output in YAML format") do
          format = :yaml
        end
        opt.on('--json', '-j', "output in JSON format") do
          format = :json
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
      options[:pattern] = argv.shift unless options[:template]
      file = argv.shift
      if file && !File.file?(file)
        $stderr.puts "No such file -- '#{file}'."
        exit 1
      end
      target = file ? File.new(file) : ARGF
      extractor = new(target, options)
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

