(define (exp-i a b)
  (if (= b 1) a)
  (define (exp-iter a b c)
    (if (= b 0) c
      (cond ((= (remainder b 2) 0) (exp-iter a (/ b 2) (* c (square a))))
        (else (exp-iter a (- b 1) (* a c)))
      )
    )
  )
  (exp-iter a b 1)
)
