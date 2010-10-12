module Regex

  # = Templates
  #
  # TODO: What about regular expressions with variable content?
  # Should these be methods rather than constants? But then how
  # would we handle named substituions?
  module Templates

    # Empty line.
    EMPTY = /^$/

    # Blank line.
    BLANK = /^\s*$/

    NUMBER = /[-+]?[0-9]*\.?[0-9]+/

    # Markup language tag, e.g \<a>stuff</a>.
    MLTAG = /<([A-Z][A-Z0-9]*)\b[^>]*>(.*?)<\/\1>/i

    # IPv4 Address
    IPV4 = /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/

    # Username
    USERNAME = /^[a-zA-Z0-9_]{3,16}$/

    # Email Address
    EMAIL = /([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)/i

    # United States phone number.
    USPHONE = /(\d\d\d[-]|\(\d\d\d\))?(\d\d\d)[-](\d\d\d\d)/

    # United States zip code.
    USZIP = /^[0-9]{5}(-[0-9]{4})?$/

    # United States social secuirty number.
    SSN = /[0-9]\{3\}-[0-9]\{2\}-[0-9]\{4\}/

    # United States dollar amount.
    DOLLARS = /\$[0-9]*.[0-9][0-9]/

    # Bank Ientification Code
    BIC = /([a-zA-Z]{4}[a-zA-Z]{2}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?)/

    #
    IBAN = /[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}([a-zA-Z0-9]?){0,16}/

    # Hexidecimal value.
    HEX = /(#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})\b)/

    # HTTP URL Address
    HTTP = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \?=.-]*)*\/?$/

    # Ruby comment block.
    RUBYBLOCK = /^=begin\s*(.*?)\n(.*?)\n=end/m

    # Ruby method definition.
    # TODO: Not quite right.
    RUBYMETHOD_WITH_COMMENT = /(^\ *\#.*?)^\s*def\s*(.*?)$/m

    #
    RUBYMETHOD = /^\ *def\s*(.*?)$/

    # By the legendary abigail. Fails to match if and only if it is matched against
    # a prime number of 1's. That is, '11' fails, but '1111' does not.
    # I once heard him talk why this works, but I forgot most of it.
    PRIMEONES = /^1?$|^(11+?)\1+$/

    # Name of all constants.
    def self.list
      constants.map{ |c| c.downcase }
    end

    # Lookup a template by name.
    def self.[](name)
      Templates.const_get(name.upcase)
    end

  end

  # Add templates to Regex module.
  include Templates

end

