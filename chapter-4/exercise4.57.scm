(rule (can-replace ?person1 ?person2)
      (and (and (job ?person1 ?job1)
	        (job ?person2 ?job2)
	        (or (same ?job1 ?job2)
	            (can-do-job ?job1 ?job2)))
           (not (same ?person1 ?person2))))

; a)
(can-replace ?person (Fect Cy D))
; b)
(and (can-replace ?someone ?paid-more)
     (salary ?paid-more ?x)
     (salary ?someone ?y)
     (lisp-value > ?x ?y))
