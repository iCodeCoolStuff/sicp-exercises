(define (install-=zero?)
  (define (=zero? p)
    (empty-termlist? p))
  (put '=zero? 'polynomial =zero?)
'done)
