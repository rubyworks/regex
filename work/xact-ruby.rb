module Rivets
module CLI

  #

  class Ginsu

    def self.start ; new.start ; end

    def initialize(argv=ARGV)
      @args, @keys = Console::Arguments.new(argv).parameters
    end

    def start
      files = @args[0]
      ExtractAndSave.test_extract(files)
    end
  end

  # Runs extracted code via a pipe.
  # The binary for this is called exrb.

  class XactRuby #Excerb

    # Shortcut for typical usage.

    def self.run
      new.run
    end

    attr_reader :exacto, :file, :handle, :argv

    def initialize( argv=ARGV )
      argv = argv.dup

      if argv.delete('--help')
        help
        exit 0
      end

      if i = argv.index('-h')
        handle = argv[i+1].strip
        argv[i+1,1] = nil
        argv.delete('-h')
      else
        handle = 'test'
      end

      if i = argv.index('-P')
        argv.delete('-P')
        file = argv.pop
        puts exact(handle)
        exit 0
      end

      file = argv.pop

      @argv   = argv
      @handle = handle
      @file   = File.expand_path(file)
      @exacto = Extractor.new(file)
    end

    # Extract the code.

    def exact
      return *@exacto.extract_block(handle)
    end

    # This runs the commented code block via a pipe.
    # This has an advantage in that all the parameters
    # that can be passed to ruby can also be passed to exrb.

    def run
      excode, offset = exact

      code = "\n"
#      code << special_requirements
      code << "require '#{file}'\n"
      code << "eval(<<'_____#{handle}_____', TOPLEVEL_BINDING, '#{file}', #{offset})\n"
      code << excode
      code << "\n_____#{handle}_____\n\n"

      cmd = ['ruby', *argv].join(' ')

      result = IO.popen(cmd,"w+") do |ruby|
        ruby.puts code
        ruby.close_write
        puts ruby.read
      end
    end

#     # Any special requirements based on handle?
#
#     def special_requirements
#       case handle
#       when 'test/unit'
#         "require 'test/unit'"
#       when 'rspec'
#         "require 'rspec'"
#       else
#         ''
#       end + "\n"
#     end

    # Show help.

    def help
      helpstr = `ruby --help`
      helpstr.sub!('ruby', 'exrb')
      puts helpstr
      puts
      puts "  -h              handle of comment block to run"
      puts "  -P              display the code block to be run"
    end


    # OLD CODE
    #
    #   # This runs the commented code block directly.
    #   # This has an advantage in that the line numbers
    #   # can be maintained.
    #
    #   def run_eval( fname, block='test' )
    #     code, offset = extract_block( fname )
    #
    #     require 'test/unit' if block == 'test'
    #     require fname
    #
    #     eval code, TOPLEVEL_BINDING, File.basename(fname), offset
    #   end
    #
    #   # This runs the commented code block via a pipe.
    #   # This has an advantage in that all the parameters
    #   # that can be passed to ruby can be passed to rubyinline.
    #
    #   def run_pipe( fname, block='test' )
    #     code, offset = extract_block( fname, block )
    #
    #     code = "require 'test/unit'\n\n" + code if block == 'test'
    #     code = "require '#{fname}'\n\n" + code
    #
    #     cmd = ['ruby', *ARGV].join(' ')
    #
    #     result = IO.popen(cmd,"w+") do |ruby|
    #       ruby.puts code
    #       ruby.close_write
    #       puts ruby.read
    #     end
    #   end

  end

end
end
