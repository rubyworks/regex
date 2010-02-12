# = Text Extraction Class
#
# Extractor is was designed particulalry for extracting source code from embedded
# comment blocks.
#
# Todo:
#   - How can we handle embedded code in stadanrd comments? Eg. #
#
class Regex
  VERSION = "1.1"

  # When the regular expression return multiple groups,
  # each is divided by the group deliminator.
  # This is the default value.
  DELIMINATOR_GROUP  = 29.chr + "\n"

  # When using repeat mode, each match is divided by
  # the record deliminator. This is the default value.
  DELIMINATOR_RECORD = 30.chr + "\n"

  require 'fileutils'
  require 'open-uri'

  require 'regex/string'
  require 'regex/command'

  # TODO: generalize to plugin
  require 'regex/templates/common'

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

  #
  #attr_reader :match

  #
  def self.load(file, options={}, &block)
    new(open(file), options, &block)
  end

  # New extractor.
  def initialize(io, options={})
    @raw     = io.read
    options.each do |k,v|
      __send__("#{k}=", v)
    end
    yield(self) if block_given?
  end

  # Read file.
  #def raw
  #  @raw ||= open(@file) # File.read(@file)
  #end

  #
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
        TEMPLATES.const_get(template.upcase)
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
        out.join(deliminator_record) #.chomp("\n") + "\n"
      else
        out.join(deliminator_group) #.chomp("\n") + "\n"
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

  #
  def structure
    repeat ? structure_repeat : structure_single
  end

  #
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

  #
  def structure_repeat
    out = extract
    if index
      out.map{ |md| [md[index]] }
    else
      out.map{ |md| md.size > 1 ? md[1..-1] : [md[0]] }
    end
  end

  #
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

  #
  def extract_single
    md = regex.match(text)
    md ? md : []
  end

  #
  def matchdata
    regex.match(text)
  end

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

  #
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

=begin
  #def extract_pattern(pattern)
    #if clip = md ? md[0] : nil
    #  offset = text[0...md.begin(0)].count("\n")
    #  return clip, offset
    #else
    #  raise "Pattern not found -- #{pattern}"
    #  return nil, nil
    #end
  #end
=end

=begin
  # Extract Block.
  def extract_block(start, stop)
    start = Regexp.new(start)
    stop  = Regexp.new(stop)

    md_start = start.match(text)
    if md_start
      md_stop = stop.match(text[md_start.end(0)..-1])
      if md_stop
        clip = text[md_start.end(0)...(md_stop.begin(0)+md_start.end(0))]
      else
        raise "Pattern not found -- #{stop}"
        return nil, nil
      end
      offset = text[0...md_start.begin(0)].count("\n")  #?
      return clip, offset
    else
      raise "Pattern not found -- #{start}"
      return nil, nil
    end
  end
=end

=begin
  #################
  # Ruby Specific #
  #################

  # Returns a Ruby comment block with a given handle.

  def extract_ruby_block_comment(handle)
    b = Regexp.escape(handle)
    if b == ''
      pattern = /^=begin.*?\n(.*?)\n=end/mi
    else
      pattern = /^=begin[ \t]+#{b}.*?\n(.*?)\n=end/mi
    end
    extract_pattern(pattern)
  end

  # Returns a Ruby method comment.

  def extract_ruby_method_comment(meth) #=nil )
    #if meth
      regexp  = Regexp.escape(meth)
      pattern = /(\A\s*\#.*?^\s*def #{regexp}/mi
      extract_pattern(pattern)
    #else
    #  prog.scan /^\s*\#/mi
    #  md = pattern_inline_all.match( prog )
    #end
  end
=end

#     # Extract the matching comment block.
#
#     def extract_block( handle='test' )
#       text = File.read(file)
#       md = pattern_block(handle).match(text)
#       code = md ? md[1] : nil
#       unless code
#         puts "Code block not found -- #{handle}"
#         exit 0 #return nil
#       end
#       offset = text[0...md.begin(1)].count("\n")
#       return code, offset
#     end
#
#     # Returns the comment inline regexp to match against.
#
#     def pattern_inline( mark )
#       m = Regexp.escape(mark)
#       /(\A\s*\#.*?^\s*def #{m}/mi
#     end
#
#     def extract_inline( fname, mark=nil )
#       prog = File.read( file )
#       if mark
#         md = pattern_inline(mark).match( prog )
#       else
#         prog.scan /^\s*\#/mi
#         md = pattern_inline_all.match( prog )
#       end
#     end

end

