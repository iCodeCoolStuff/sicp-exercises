; Commented out lines because Scheme implementation delays computation.
(define (memo-proc proc)
  (let ((already-run? false) (result false))
    (lambda ()
      (if (not already-run?)
	  (begin (set! result (proc))
	    (set! already-run? true)
	    result)
	  result))))
;(define (delay exp)
  ;(lambda () exp))
  ;(memo-proc (lambda () exp)))
;(define (force promise) (promise))
(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))
;(define (cons-stream a b)
  ;(cons a (delay b)))
(define the-empty-stream '())
(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))
(define (stream-map proc s)
  (if (stream-null? s)
      the-empty-stream
      (cons-stream (proc (stream-car s))
		   (stream-map proc (stream-cdr s)))))
(define (stream-for-each proc s)
  (if (stream-null? s)
      'done
      (begin (proc (stream-car s))
             (stream-for-each proc (stream-cdr s)))))
(define (display-stream s)
  (stream-for-each display-line s))
(define (display-line x) (newline) (display x))
(define (stream-enumerate-interval low high)
  (if (> low high)
      the-empty-stream
      (cons-stream
	low
	(stream-enumerate-interval (+ low 1) high))))
(define (stream-filter pred stream)
  (cond ((stream-null? stream) the-empty-stream)
        ((pred (stream-car stream))
         (cons-stream (stream-car stream)
		      (stream-filter
		        pred
		        (stream-cdr stream))))
        (else (stream-filter pred (stream-cdr stream)))))
(define (show x)
  (display-line x)
  x)

(define sum 0)
(define (accum x) (set! sum (+ x sum)) sum)
(define seq
  (stream-map accum
	      (stream-enumerate-interval 1 20)))
(define y (stream-filter even? seq))
(define z
  (stream-filter (lambda (x) (= (remainder x 5) 0))
		 seq))

(stream-ref y 7)
; 136
(display-stream z)
;10
;15
;45
;55
;105
;120
;190
;210

; The responses would differ because the values in seq would have to be evaluated again which would modify sum so that the incorrect
; values are outputted.
