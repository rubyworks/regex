# Regex ("Like a Knife")

[Website](http://rubyworks.github.com/regex) /
[Report Issue](http://github.com/rubyworks/regex/issues) /
[Source Code](http://github.com/rubyworks/regex) /
[Chat Room](irc://irc.freenode.net/rubyworks) /
[![Build Status](https://secure.travis-ci.org/rubyworks/regex.png)](http://travis-ci.org/rubyworks/regex) /
[![Gem Version](https://badge.fury.io/rb/regex.png)](http://badge.fury.io/rb/regex)


## About

Yea, I know what you are going to say. "I can do that with ____" Fill in the blank
with `grep`, `awk`, `sed`, `perl`, so on and on and on. But honestly, none of these tools are
"Langauge 2.0" (read "post-Ruby"). What I want is a simple command-line tool that
gives me quick access to a Regular Expression engine. No more and no less.

Now I could have written this in Perl. I'm sure it would just as good, if not
better since Perl's Regular Expression engine rocks, or so I hear. But Ruby's is
pretty damn good too, and getting better (with 1.9+). And since I know Ruby very
well. Well that's what you get.


## USAGE

For detailed explication and examples of usage refer to the
[User Docs](http://wiki.github.com/rubyworks/regex), the
[QED Docs](http://github.com/rubyworks/regex/docs/qed) and the
[API Docs](http://github.com/rubyworks/regex/docs/api).

In brief, usage simply entails supplying a regular expression and a list of files
to be searched to the `regex` command.

    $ regex '/=begin.*?\n(.*)\n=end/' sample.rb

This example does exactly what you would expect --returns the content between
the first `=begin ... =end` clause it comes across. To see all such
block comments, as you would expect, you can use add `g` regular
expression mode flag.

    $ regex '/=begin.*?\n(.*)\n=end/g' sample.rb

Alternatively you can use the `--repeat/--global/-g` option.

    $ regex -g '/=begin.*?\n(.*)\n=end/' sample.rb

Notice that in all these examples we have used single quotes to wrap the
regular expression. This is to prevent the shell from expanding `*`
and `?` marks.

By default regex produces string output. Regular expression groups are delimited
by ASCII 29 (035 1D) END OF GROUP, and repeat matches are delimited by
ASCII character 30 (036 1E) END OF RECORD.

Instead of string output, regex also supports YAML and JSON formats using the
`--yaml/-y` and `--json/-j` options.

    $ regex -y -g '/=begin.*?\n(.*)\n=end/' sample.rb

In this case the returned matches are delimited using as an array of arrays.

To get more information that just the match results use the `--detail/-d`
option.

Also, we can do without the `/ /` deliminators on the regular
expression if we use the `--search/-s` option instead. Going back to
our first example:

    $ regex -s '=begin.*?\n(.*)\n=end' sample.rb

To replace text, use the `--replace/--r` option.

    $ regex --yaml --repeat -s 'Tom' -r 'Bob' sample.rb

This will replace every occurrence of "Tom" with "Bob" in the `sample.rb`
file. By default `regex` will backup any file it changes by adding a
`.bak` extension to the original copy.

Check out the `--help` and I am sure the rest will be smooth sailing.
But it you want more information, then do us the good favor of jumping over
to the [wiki](http://wiki.github.com/rubyworks/regex). Feel free to add
additional information there to help others.


## OUTPUT

Regex has three output modes. YAML, JSON and standard text. The standard
text output is unique in that it utilizes special ASCII characters
to separate matches and regex groups. ASCII 29, called the *record separator*,
is used to separate repeat matches. ASCII 30, called the *group separator*, is
is used to separate regular expression groups.


## STATUS

The project is maturing but still a touch wet behind the ears. So don't be too
surprised if it doesn't have every feature under the sun just yet, or that every
detail is going to work absolutely peachy. But hey, if something needs fixing or
a feature needs adding, well then get in there and send me a patch. Open source
software is built on *TEAM WORK*, right?


## COPYRIGHT

Copyright &copy; 2010 Rubyworks

Regex is licensed under the terms of the *FreeBSD* license.

See LICENSE.txt file for details.

