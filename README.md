# What is this ?

This library is an implementation of msgpack encoder/decoder for RealStudio, an IDE/language similar
to VisualBasic but cross platform.

# Status

Every data types are supported except uin64 and int64 (RealStudio does not seem to handle them correctly althought
it supports them...), another thing to note is that maps are mapped to Dictionary which are really resources monster
in the language so it is better to avoid to work with big ones (small ones are fine).

If you want to see the performance just compile and execute msgpack.rbvcp after ensuring the App.TEST_MODE constants
is set to true to run the tests and time them.
(the timing of decoding also include testing the decoded results which taks more time than encoding and decoding for
some types)

# RPC
Working with libraries is a pain with RealStudio so I included the RPC Class I use but be aware that this is not based
on the msgpack-RPC document so do not expect it to run with any other implementations (the encoding/decoding is 100%
compliant with the specs though).


# Using it
If someone wants to use it I suggest using a git submodule or symlink the folder into your application folder because
RealStudio, as advanced as it is (joke) is not able to properly handle files outside its folder and hash no proper
system in place for external libraries.
