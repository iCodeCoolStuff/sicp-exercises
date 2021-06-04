(define (dot-product v w)
  (accumulate + 0 (map * v w)))

(define (matrix-*-vector m v)
  (map (lambda (x) (map * x v)) m))

(define (transpose mat)
  (accumulate-n (lambda (x y) (cons x y)) () mat))

(define (matrix-*-matrix m n)
  (let ((cols (transpose n)))
	(map (lambda (x) (map (lambda (z) (accumulate + 0 z)) (map (lambda (y) (map * x y)) cols))) m)))
  
(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence)
	  (accumulate op initial (cdr sequence)))))

(define (accumulate-n op init seqs)
  (if (null? (car seqs))
      ()
      (cons (accumulate op init (map (lambda (x) (car x)) seqs))
	    (accumulate-n op init (map (lambda (x) (cdr x)) seqs)))))

(define (test)
  ;(matrix-*-vector (list (list 1 2 3 4) (list 5 6 7 8) (list 9 10 11 12)) (list 1 2 3 4)))
  ;(transpose (list (list 1 2 3) (list 4 5 6) (list 7 8 9))))
  (matrix-*-matrix (list (list 1 2 3) (list 4 5 6) (list 7 8 9)) (list (list 1 2 3) (list 4 5 6) (list 7 8 9))))
