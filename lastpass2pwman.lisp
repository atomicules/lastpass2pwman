(let ((in (open "lastpass.csv" :if-does-not-exist nil)))
    (when in
	      (format t "~a~%" (read-line in))
		      (close in)))

(let ((in (open "lastpass.csv" :if-does-not-exist nil)))
    (when in
	      (read-csv-line (read-line in))
		      (close in)))

(let ((in (open "lastpass.csv" )))
	(loop for line = (read-line in nil)
		while line do (format t "~a~%" line))
		      (close in))
;Use csv-parser. Can't get cl-csv to build

(csv-parser:read-csv-line (open "lastpass.csv"))

(csv-parser:map-csv-file "lastpass.csv" 1)

(defun pwmanln (ln)
	(format t "<PwItem><name>~a</name><host>~a</host><user>~a</user><passwd>~a</passwd><launch></launch></PwItem>~%" (fifth ln) (first ln) (second ln) (if (null (third ln)) (fourth ln) (third ln)))
)

(csv-parser:map-csv-file "lastpass.csv" (function pwmanln))

;that is basically it already. Need to write out to a file. 
;Also could do with checking how secure notes are parsed. Bit screwey for them
;Ah, by the looks of it this is the extra field.
;So need to do an if ps NIL, then get that field or if host is sn, etc.
;
;to pass the funciton

;first ln , etc
;then use concatenate

(format nil "<xml stuff>~a.</xml stuff><xml>~a</xml>%" (first ln) (nth 1 ln))

;Shoud nbe easy peasy
(with-open-file (stream "pwman.txt" :direction :output :if-exists :supersede)
    (format stream "<?xml version=\"1.0\"?>~%<PWMan_PasswordList version=\"3\">~%<PwList name=\"Main\">~%")
	
	
	)
