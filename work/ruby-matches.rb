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

