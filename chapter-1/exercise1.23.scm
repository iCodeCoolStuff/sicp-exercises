(define (smallest-divisor n ) (find-divisor n 2))
(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
	((divides? test-divisor n) test-divisor)
	(else (find-divisor n (next test-divisor)))))
(define (divides? a b) (= (remainder b a) 0))

(define (next n)
  (if (= (remainder n 2) 0) 3 (+ n 2)))
