## Searching Files

Given a file a.txt containing:

    This is file a.txt.
    This is an example.

And given a file b.txt containing:

    This is file b.txt.
    This is another example.

Then invoking the command:

    $ regex -s example a.txt b.txt

Should produce:

    example

In this case it found the first match and returned it.
To handle a global search we add the `-g` flag.

Invoking the command:

    $ regex -g -s example a.txt b.txt

Will give a more complex result.

    @out.assert == "example\036\nexample\n"

