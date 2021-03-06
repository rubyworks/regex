# Regex::Replacer

Regex can also be used to do search and replace across multiple
strings or IO objects, includeing files.

    require 'regex'

To perform search and replace procedure we create a Regex::Replacer object.
The constructor method takes a Hash of options which set universal parameters
to apply to all search and replace rules. Usually, each individual rule
will specify it's own options, so for this example we provide none.

    replacer = Regex::Replacer.new

Rules are added via the #rule method.

    replacer.rule('World', 'Planet Earth')
    replacer.rule('!', '!!!')

Rules are applied in the order they were defined. If there rules overlap
in their effects this can be signifficant.

Now, lets say we have that famous String,

    string = "Hello, World!"

We use the #apply method to actually perform the substitutions.

    replacer.apply(string)

The replacements occur in place. Since in this case we are performing
the serach and replace on a String object, we can see the change 
has taken place.

    string.assert == "Hello, Planet Earth!!!"

As we mentioned at the beginning, substitutions can be applied to IO
objects in general, so long as they they can be reopended for writing.

    require 'stringio'

    io = StringIO.new("Hello, World!")

    replacer.apply(io)

    io.read.assert == "Hello, Planet Earth!!!"

If +io+ were a File object, rather than a StringIO, the file would
be changed on disk. As a precaution a backup file can be written 
with the name of file plus a '.bak' extension in the same directory as
the file. To turn on the backup option, either supply it as an option
to the constructor, or set it via the writer method.

    replacer.backup = true

(TODO: Example of a file search and replace.)

