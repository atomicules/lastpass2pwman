#Lastpass2pwman

CLisp script to convert [Lastpass](https://lastpass.com) CSV export to [pwman](http://pwman.sourceforge.net) format.

Mainly done as a little learning exercise in Lisp for me, but also because I use Lastpass and also want to use a command line based password manager. Unfortunately there doesn't seem to be a command line client for Lastpass so I'm going to use pwman and every so often do a one way update of passwords.

## How to use

Developed and tested in SBCL. Use as follows

	sbcl --script /path/to/this/script </path/to/lastpass/export>

The path to the Lastpass export is optional. If not supplied assumes file is called "lastpass.csv" and is in current directory. Exports a file called "pwman.txt" to current directory. This is in plain text and so needs encoding via GPG: 

	gpg -r <yourgpgid@domain.com> -o ~/.pwman.db -e pwman.txt

This will encrypt the file and overwrite the pwman password database. Remember to delete the plain text files afterwards!
