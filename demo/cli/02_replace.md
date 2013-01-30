## Search and Replace on Files

Given a file a.txt containing:

    This is file a.txt.
    This is an example.

And given a file b.txt containing:

    This is file b.txt.
    This is another example.

Then invoking the command:

    $ regex -s example -r EXAMPLE a.txt b.txt

Should result in a new file a.txt containing:

    This is file a.txt.
    This is an EXAMPLE.

And should result in a new file b.txt containing:

    This is file b.txt.
    This is another EXAMPLE.

