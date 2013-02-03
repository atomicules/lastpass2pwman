#Lastpass2pwman

CLisp script for SBCL to convert [Lastpass](https://lastpass.com) CSV export to [PWman](http://pwman.sourceforge.net) format.

Mainly done as a little learning exercise in Lisp for me, but also because I use Lastpass and also want to use a command line based password manager. Unfortunately there doesn't seem to be a command line client for Lastpass so I'm going to use PWman and every so often do a one way update of passwords.

## How to use

Developed and tested in SBCL. Use as follows

	sbcl --script /path/to/this/script <gpg id used with pwman> </path/to/lastpass/export>

The path to the Lastpass export is optional. If not supplied assumes file is called "lastpass.csv" and is in current directory. The script works by first exporting a plain text file called "pwman.txt" to current directory, however, this is then immediately encrypted via GPG and replaces the `.pwman.db` file. Both plain text files (the Lastpass export and `pwman.txt`) are then deleted - unless an error occurs with the encryption, in which case the script notifies the user and leaves the files.

## Known issues

PWman has a maximum password length of 64 characters therefore secure notes are stored in the launch field of PWman. Since the whole file is encrypted it doesn't really matter which field is used. The launch field allows up to 256 characters. If your secure notes are longer than this, then PWman will truncate them when saving. Also, note that although PWman will store 256 characters correctly it won't necessarily display them all correctly (the field was intended for displaying a single line of text), but the data will be in the file.
