;;; To allow parallel execution of any number of thunks, for
;;; effect.  The values are discarded.

(define disallow-preempt-current-thread
  (access disallow-preempt-current-thread
	  (->environment '(runtime thread))))

(define allow-preempt-current-thread
  (access allow-preempt-current-thread
	  (->environment '(runtime thread))))

(define (kill-thread thread)
  (let ((event
	 (lambda ()
	   (exit-current-thread 'RIP))))
    (without-interrupts
     (lambda ()
       (case (thread-execution-state thread)
	 ((STOPPED) (restart-thread thread #t event))
	 ((DEAD) unspecific)
	 (else (signal-thread-event thread event)))))))

(define (parallel-execute . thunks)
  (let ((my-threads '()))
    (define (terminator)
      (without-interrupts
       (lambda ()
	 (for-each kill-thread my-threads)
	 (set! my-threads '())
	 unspecific)))
    (without-interrupts
     (lambda ()
       (set! my-threads
	     (map (lambda (thunk)
		    (let ((thread (create-thread #f thunk)))
		      (detach-thread thread)
		      thread))
		  thunks))
       unspecific))
    terminator))

(define (make-serializer)
  (let ((mutex (make-thread-mutex)))
    (define (serialized f)
      (define (serialized-f . args)
	(with-thread-mutex-locked mutex
				  (lambda ()
				    (apply f args))))
      serialized-f)
    serialized))

(define output-serialized (make-serializer))

(define write-line
  (output-serialized write-line))

(define display
  (output-serialized display))

(define write
  (output-serialized write))
