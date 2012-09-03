;CLisp script for SBCL to convert lastpass CSV export to pwman format
;See README for usage instructions

;Load quicklisp
(load "~/.sbclrc")
;Load libraries
(ql:quickload "csv-parser")
(ql:quickload "xmls")

;Note to self: Start with 2nd *posix-argv* as first is always /path/to/sbcl, etc.
;gpgid to encrypt file with
(defparameter gpgid (second *posix-argv*))
;Check for supplied filename, otherwise assume called lastpass.csv
(defparameter infile (if (null (third *posix-argv*)) "lastpass.csv" (third *posix-argv*)))
;read the lastpass file and convert to PWman format
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
					(xmls:toxml (third ln))))) :skip-lines 1)
	(format stream "</PwList></PWMan_PasswordList>"))
;Move original file to backup
(rename-file (concatenate 'string (sb-unix::posix-getenv "HOME") "/.pwman.db") (concatenate 'string (sb-unix::posix-getenv "HOME") "/.pwman.db.bak")) 
;gpg encrpyt the file
(let ((proc (sb-ext:run-program "gpg" (list "-r" gpgid "-o" (concatenate 'string (sb-unix::posix-getenv "HOME") "/.pwman.db") "-e" "pwman.txt") :search :environment)))
	(if (= 0 (sb-ext:process-exit-code proc))
		;If that was successful, then delete the un-encrypted files
		(progn 
			(delete-file infile) 
			(delete-file "pwman.txt"))
		;If not restore backup and leave plain text files (otherwise will fail next time on above rename)
		(progn
			(rename-file (concatenate 'string (sb-unix::posix-getenv "HOME") "/.pwman.db.bak") (concatenate 'string (sb-unix::posix-getenv "HOME") "/.pwman.db")) 
			(print "Couldn't encrypt file, plain text files have not been deleted"))))
