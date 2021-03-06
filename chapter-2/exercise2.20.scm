(define (same-parity x . y)
  (if (odd? x)
      (filter odd? (cons x y))
      (filter even? (cons x y))))

(define (filter predicate lst)
  (define (rec l1 l2)
    (cond ((null? l2) l1)
          ((predicate (car l2)) (cons (car l2) (rec l1 (cdr l2))))
	  (else (rec l1 (cdr l2)))))
  (rec () lst))

(define (test)
  (display (same-parity 1 2 3 4 5 6 7))(newline)
  (display (same-parity 2 3 4 5 6 7))(newline))
