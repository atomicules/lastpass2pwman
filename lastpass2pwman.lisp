;CLisp script for SBCL to convert lastpass CSV export to PWman format
;See README for usage instructions

;Load quicklisp
(load "~/.sbclrc")
;Load libraries
(ql:quickload "csv-parser")
(ql:quickload "xmls")

;Note to self: Start with 2nd *posix-argv* as first is always /path/to/sbcl, etc
;gpgid to encrypt file with
(defparameter gpgid (second *posix-argv*))
;Check for supplied filename, otherwise assume called lastpass.csv
(defparameter infile (if (null (third *posix-argv*)) "lastpass.csv" (third *posix-argv*)))
;read the lastpass file and build up hash for each group
(defparameter *lastpass* (make-hash-table))
(csv-parser:map-csv-file infile
	(lambda (ln)
		(if (gethash (read-from-string (substitute #\- #\Space (sixth ln))) *lastpass*) ;Group
			;Note, without (intern (string-upcase or (read-from-string keys aren't set properly and something bizarre happens
			(setf
				(gethash (read-from-string (substitute #\- #\Space (sixth ln))) *lastpass*)
				(append (gethash (read-from-string (substitute #\- #\Space (sixth ln))) *lastpass*) (list ln))) ;append key
			(setf
				(gethash (read-from-string (substitute #\- #\Space (sixth ln))) *lastpass*)
				(list ln)))) :skip-lines 1) ;create key
;Write hash out as XML
(with-open-file (stream "pwman.txt" :direction :output :if-exists :supersede)
	(format stream "<?xml version=\"1.0\"?><PWMan_PasswordList version=\"3\"><PwList name=\"Main\">")
	;For each key in hash
	(with-hash-table-iterator (group *lastpass*)
		(loop
			(multiple-value-bind (returned? groupname groupentries) (group)
			(if returned?
				(progn
					(format stream "<PwList name=\"~a\">" groupname)
					;Then loop through each entry in group
					(loop for entry in groupentries
						do (format stream
							"<PwItem><name>~a</name><host>~a</host><user>~a</user><passwd>~a</passwd><launch></launch></PwItem>"
							(xmls:toxml (fifth entry))
							(xmls:toxml (first entry))
							(xmls:toxml (second entry))
							(if (null (third entry)) ;Secure Notes have no password
								(xmls:toxml (fourth entry)) ;Use extra field if Secure Note
								(xmls:toxml (third entry)))))
					(format stream "</PwList>"))
				(return)))))
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
