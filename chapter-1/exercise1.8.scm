(define (improve guess x)
  (/ (+ (/ x (square guess)) (* 2 guess)) 3)
)

(define (good-enough? guess x)
  (< (abs (- (* guess guess guess) x)) 0.001)
)

(define (cube-iter guess x)
  (if (good-enough? guess x)
    guess
    (cube-iter (improve guess x) x))
)
