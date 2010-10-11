require 'fileutils'
require 'open-uri'
require 'regex/string'

module Regex

  # TODO: Support multiple files ?
  # TODO: Output mode that includes file name and line number ?

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

    # Escape expression.
    attr_accessor :escape

    # Repeat Match.
    attr_accessor :repeat

    # Output format.
    attr_accessor :format

    # Provide detailed output.
    attr_accessor :detail

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
            flags = 0
            flags + Regexp::MULTILINE
            flags + Regexp::IGNORECASE if insensitive
            if escape
              Regexp.new(Regexp.escape(pattern), flags)
            else
              Regexp.new(pattern, flags)
            end
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
        to_s_txt
      end
    end

    #
    def to_s_yaml
      require 'yaml'
      if detail
        detailed_structure.to_yaml
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
        detailed_structure.to_json
      else
        structure.to_json
      end
    end

    #
    def to_s_txt
      if detail
        out = []
        detailed_structure.each do |c|
          c.each do |m, x|
            out << m
            x.each do |r|
              out << "  %s,%s %s" % ["#{r['line']}", "#{r['char']}", "#{r['match']}"]
            end
          end
        end
        out.join("\n")
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
    def detailed_structure
      data = []
      [extract].flatten.each do |md|
        c = []
        m = []
        md.size.times do |i|
          m[i] = {}
          m[i]['match'] = md[i]
          m[i]['char']  = md.offset(i)[0] #, m[i]['finish'] = *md.offset(i)
          m[i]['line']  = line_at(m[i]['char'])
        end
        data << {md.to_s => m}
      end
      data
      #repeat ? data : data.first
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

    def line_at(char)
      text[0..char].count("\n") + 1
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
      format  = nil
      options = {}
      parser = OptionParser.new do |opt|
        opt.on('--template', '-t NAME', "select a built-in regular expression") do |name|
          options[:template] = name
        end
        opt.on('--search', '-s PATTERN', "search for regular expression") do |re|
          options[:pattern] = re
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
        opt.on('--detail', '-d', "provide match details") do
          options[:detail] = :json
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

      file = argv.shift
      if file && !File.file?(file)
        $stderr.puts "No such file -- '#{file}'."
        exit 1
      end
      target  = file ? File.new(file) : ARGF

      extract = new(target, options)
      begin
        puts extract.to_s(format)
      #rescue => error
      #  if $DEBUG
      #    raise error
      #  else
      #    abort error.to_s
      #  end
      end
    end

  end

end

