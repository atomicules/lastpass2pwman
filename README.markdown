#Lastpass2pwman

CLisp script for SBCL to convert [Lastpass](https://lastpass.com) CSV export to [PWman](http://pwman.sourceforge.net) format.

Mainly done as a little learning exercise in Lisp for me, but also because I use Lastpass and also want to use a command line based password manager. Unfortunately there doesn't seem to be a command line client for Lastpass so I'm going to use PWman and every so often do a one way update of passwords.

## How to use

Developed and tested in SBCL. Use as follows

	sbcl --script /path/to/this/script <gpg id used with pwman> </path/to/lastpass/export>

The path to the Lastpass export is optional. If not supplied assumes file is called "lastpass.csv" and is in current directory. The script works by first exporting a plain text file called "pwman.txt" to current directory, however, this is then immediately encrypted via GPG and replaces the `.pwman.db` file. Both plain text files (the Lastpass export and `pwman.txt`) are then deleted - unless an error occurs with the encryption, in which case the script notifies the user and leaves the files.
