;CLisp script to convert lastpass CSV export to pwman format
;Tested in SBCL. Use as follows
;
;	sbcl --script /path/to/this/script </path/to/lastpass/export>
;
;The path to the Lastpass export is optional. If not supplied assumes file is
;called "lastpass.csv" and is in current directory. Exports a file called
;"pwman.txt" to current directory. This is in plain text and so needs encoding 
;via GPG. 
;
;	gpg -r <yourgpgid@domain.com> -o ~/.pwman.db -e pwman.txt
;
;This will overwrite the pwman password database
;Remember to delete the plain text files afterwards!

;Load quicklisp
(load "~/.sbclrc")
;Load libraries
(ql:quickload "csv-parser")
(ql:quickload "xmls")

;Check for supplied filename, otherwise assume called lastpass.csv
;It's 2nd *posix-argv* as first is always /path/to/sbcl, etc.
(defparameter infile (if (null (second *posix-argv*)) "lastpass.csv" (second *posix-argv*)))

(with-open-file (stream "pwman.txt" :direction :output :if-exists :supersede)
	(format stream "<?xml version=\"1.0\"?><PWMan_PasswordList version=\"3\"><PwList name=\"Main\">")
	(csv-parser:map-csv-file infile 
		(lambda (ln)
			(format stream
				"<PwItem><name>~a</name><host>~a</host><user>~a</user><passwd>~a</passwd><launch></launch></PwItem>"
				(xmls:toxml (fifth ln))
				(xmls:toxml (first ln))
				(xmls:toxml (second ln))
				(if (null (third ln)) ;Secure Notes have no password 
					(xmls:toxml (fourth ln)) ;Use extra field if Secure Note
					(xmls:toxml (third ln))))))
	(format stream "</PwList></PWMan_PasswordList>"))
