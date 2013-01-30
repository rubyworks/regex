# Regex class

Regex is really meant to be used on the command-line since
it is really nothing more than a front end to Ruby's regular
expression engine. But we will demonstrate it's use here in
code just the same, and to help ensure code quality.

First we need to require the Regex library.

    require 'regex'

Now let's create some material to work with.

    text = "We will match against this string."

Now we can then create a Regex object using the text.
We will also suppoly a matching pattern, as none of
the matching functions will work without providing
a pattern or the name of built-in pattern template.

    rx = Regex.new(text, :pattern=>'\w+')

We can see that the Regex object has converted the pattern
into the expected regular expression via the #regex method.

    rx.regex.assert == /\w+/

Under the hood, Regex has split the process of matching,
organizing and formating the results into separate methods.
We can use the #structure method to see thematch results
organized into uniform arrays.

    rx.structure.assert == %w{We}

Whereas the last use only returns a single metch, if we turn
on repeat mode we can see every word.

    rx.repeat = true

    rx.structure.assert == %w{We will match against this string}.map{ |e| [e] }

Notice that repeat mode creates an array in an array.

