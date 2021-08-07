(define (make-wire)
  (let ((signal 0)
	(actions '()))
    (define (set-signal! new-value)
      (begin (set! signal new-value)
	     (execute-actions actions)
	'ok))
    (define (execute-actions alist)
      (cond ((null? alist) 'done)
	    (else
	      ((car alist))
	      (execute-actions (cdr alist)))))
    (define (add-action! action)
      (begin (set! actions (cons action actions))
	     (action)
	     'ok))
    (define (dispatch m)
      (cond ((eq? m 'get-signal) signal)
	    ((eq? m 'set-signal!) set-signal!)
	    ((eq? m 'add-action!) add-action!)
	    (else (error "Unknown operation -- MAKE-WIRE" m))))
    dispatch))
(define (set-signal! wire new-value)
  ((wire 'set-signal!) new-value))
(define (get-signal wire)
  (wire 'get-signal))
(define (add-action! wire proc-of-no-arguments)
  ((wire 'add-action!) proc-of-no-arguments))
(define (inverter input output)
  (define (invert-input)
    (let ((new-value (logical-not (get-signal input))))
      (after-delay inverter-delay
		   (lambda () (set-signal! output new-value)))))
  (add-action! input invert-input) 'ok)
(define (logical-not s)
  (cond ((= s 0) 1)
        ((= s 1) 0)
	(else (error "Invalid signal" s))))
(define (and-gate a1 a2 output)
  (define (and-action-procedure)
    (let ((new-value
	    (logical-and (get-signal a1) (get-signal a2))))
      (after-delay
	and-gate-delay
	(lambda () (set-signal! output new-value)))))
  (add-action! a1 and-action-procedure)
  (add-action! a1 and-action-procedure)
  'ok)
(define (logical-and s1 s2)
  (cond ((not (and (or (= s1 1) (= s1 0)) (or (= s2 1) (= s2 0)))) ; Either s1 or s2 is neither 1 nor 0
	 (error "Invalid signal" (list s1 s2)))
        ((and (= s1 1) (= s2 1)) 1)
	(else 0)))
(define (or-gate o1 o2 output)
  (define (or-action-procedure)
    (let ((new-value
	    (logical-or (get-signal o1) (get-signal o2))))
      (after-delay
	or-gate-delay
	(lambda () (set-signal! output new-value)))))
  (add-action! o1 or-action-procedure)
  (add-action! o2 or-action-procedure)
  'ok)
(define (after-delay delay-time proc)
  (proc))
(define inverter-delay 0)
(define and-gate-delay 0)
(define or-gate-delay 0)

(define (or-gate o1 o2 output)
  (let ((a1-out (make-wire))
	(a2-out (make-wire))
	(n1-in (make-wire))
	(n2-in (make-wire))
	(n3-out (make-wire)))
    (and-gate o1 o1 a1-out)
    (inverter a1-out n1-in)
    (and-gate o2 o2 a2-out)
    (inverter a2-out n2-in)
    (and-gate a1-out a2-out n3-out)
    (inverter n3-out output)))

; The delay time of the or-gate will be equal to 3x the delay time of an and-gate plus 3x the delay time of an inverter.