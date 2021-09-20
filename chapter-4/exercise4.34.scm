(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
        ((variable? exp) (lookup-variable-value exp env))
	((quoted? exp) (text-of-quotation exp env))
	((assignment? exp) (eval-assignment exp env))
	((definition? exp) (eval-definition exp env))
	((let? exp) (eval (let->combination exp) env))
	((if? exp) (eval-if exp env))
	((lambda? exp) (make-procedure (lambda-parameters exp)
				       (lambda-body exp)
				       env))
	((begin? exp)
	 (eval-sequence (begin-actions exp) env))
	((cond? exp) (eval (cond->if exp) env))
	((application? exp)
	 (apply (actual-value (operator exp) env)
		(operands exp)
		env))
	(else
	  (error "Unknown expression type: EVAL" exp))))

(define (modifier p)
  (cond ((not (list? p)) 'none)
	((lazy? p) 'lazy)
	((lazy-memo? p) 'lazy-memo )
	(else (error "Unknown modifier: MODIFIER" p))))

(define (modifiers params)
  (map modifier params))

(define (map-modifiers modifiers arguments env)
  (cond ((null? modifiers) '())
        ((eq? (car modifiers) 'none)
	 (cons (car arguments)
	       (map-modifiers (cdr modifiers)
			      (cdr arguments) env)))
	((eq? (car modifiers) 'lazy)
	 (cons (make-lazy (car arguments) env)
	       (map-modifiers (cdr modifiers)
			      (cdr arguments) env)))
	((eq? (car modifiers) 'lazy-memo)
	 (cons (make-lazy-memo (car arguments) env)
	       (map-modifiers (cdr modifiers)
			      (cdr arguments) env)))
	(else (error "Unknown modifier: MAP-MODIFIERS" modifiers
		                                       arguments
						       env))))

(define apply-in-underlying-scheme apply)
(define (apply procedure arguments env)
  (cond ((primitive-procedure? procedure)
	 (if (strict? procedure)
	     (apply-primitive-procedure
	       procedure
	       (list-of-arg-values arguments env))
	     (apply-primitive-procedure
	       procedure
	       (list-of-delayed-args arguments env))))
        ((compound-procedure? procedure)
	 (eval-sequence
	   (procedure-body procedure)
	   (extend-environment
	     (procedure-parameters procedure)
	     (list-of-delayed-args arguments env)
	     (procedure-environment procedure))))
	(else
	  (error
	    "Unknown procedure type: APPLY" procedure))))

(define (list-of-arg-values exps env)
  (if (no-operands? exps)
      '()
      (cons (actual-value (first-operand exps) env)
	    (list-of-arg-values (rest-operands exps)
				env))))

(define (list-of-delayed-args exps env)
  (if (no-operands? exps)
      '()
      (cons (make-memoized-thunk (first-operand exps) env)
	    (list-of-delayed-args (rest-operands exps)
				  env))))

(define (actual-value exp env)
  (force-it (eval exp env)))

(define (thunk-exp thunk) (cadr thunk))
(define (thunk-env thunk) (caddr thunk))
(define (thunk-value evaluated-thunk) (cadr evaluated-thunk))
(define (make-memoized-thunk exp env)
  (list 'memoized-thunk exp env))
(define (make-thunk exp env)
  (list 'thunk exp env))
(define (thunk? obj)
  (tagged-list? obj 'thunk))
(define (memoized-thunk? obj)
  (tagged-list? obj 'memoized-thunk))
(define (evaluated-thunk? obj)
  (tagged-list? obj 'evaluated-thunk))

(define (force-it obj)
  (cond ((memoized-thunk? obj)
	 (let ((result (actual-value
			 (thunk-exp obj)
			 (thunk-env obj))))
	   (set-car! obj 'evaluated-thunk)
	   (set-car! (cdr obj) result)
	   (set-cdr! (cdr obj) '())
	   result))
	   ((evaluated-thunk? obj)
	    (thunk-value obj))
	   ((thunk? obj)
	    (actual-value (thunk-exp obj) (thunk-env obj)))
	   (else obj)))

(define (list-of-values exps env)
  (if (no-operands? exps)
      '()
      (cons (eval (first-operand exps) env)
	    (list-of-values (rest-operands exps) env))))

(define (eval-if exp env)
  (if (true? (actual-value (if-predicate exp) env))
      (eval (if-consequent exp) env)
      (eval (if-alternative exp) env)))

(define (eval-sequence exps env)
  (cond ((last-exp? exps) (eval (first-exp exps) env))
	(else (eval (first-exp exps) env)
	      (eval-sequence (rest-exps exps) env))))

(define (eval-assignment exp env)
  (set-variable-value! (assignment-variable exp)
		       (eval (assignment-value exp) env)
		       env)
  'ok)

(define (eval-definition exp env)
  (define-variable! (definition-variable exp)
		    (eval (definition-value exp) env)
		    env)
  'ok)

(define (self-evaluating? exp)
  (cond ((number? exp) true)
	((string? exp) true)
	((cons? exp) true)
	(else false)))

(define (variable? exp) (symbol? exp))
(define (quoted? exp) (tagged-list? exp 'quote))
(define (text-of-quotation exp env)
  (let ((text (cadr exp)))
    (if (pair? text)
	(eval (list 'cons (list 'quote (car text))
		          (list 'quote (cdr text))) env)
        text)))

(define (tagged-list? exp tag)
  (if (pair? exp)
      (eq? (car exp) tag)
      false))

(define (assignment? exp)
  (tagged-list? exp 'set!))
(define (assignment-variable exp) (cadr exp))
(define (assignment-value exp) (caddr exp))
(define (make-assignment var exp) (list 'set! var exp))
(define (definition? exp)
  (tagged-list? exp 'define))

(define (lazy? p)      (eq? (cadr p) 'lazy))
(define (lazy-memo? p) (eq? (cadr p) 'lazy-memo))

(define (make-lazy exp env) (make-thunk exp env))
(define (make-lazy-memo exp env) (make-memoized-thunk exp env))

(define (mapped-definition exp)
  (define (not-modified? lst)
    (cond ((null? lst) true)
          ((list? (car lst)) false)
	  (else (not-modified? (cdr lst)))))
  (define (map-modifier p)
    (cond ((not (list? p)) p)
	  ((lazy? p) (make-lazy p))
	  ((lazy-memo? p) (make-lazy-memo p))
	  (else (error "Unknown modifier: MAP-MODIFIER" p))))
  (if (not-modified? (cdadr exp))
      (make-lambda (cdadr exp)
		   (cddr exp))
      (make-lambda (actual-parameters exp)
	           (cons (make-lambda (actual-parameters exp)
			              (cddr exp))
	                 (map map-modifier (cdadr exp))))))

(define (actual-parameters exp)
  (define (parameter p)
    (if (list? p) (car p) p))
  (map parameter exp))
(define (definition-variable exp)
  (if (symbol? (cadr exp))
      (cadr exp)
      (caadr exp)))
(define (definition-value exp)
  (if (symbol? (cadr exp))
      (caddr exp)
      (make-lambda (cdadr exp)
		   (cddr exp))))

(define (lambda? exp) (tagged-list? exp 'lambda))
(define (lambda-parameters exp) (cadr exp))
(define (lambda-body exp) (cddr exp))
(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))
(define (if? exp) (tagged-list? exp 'if))
(define (if-predicate exp) (cadr exp))
(define (if-consequent exp) (caddr exp))
(define (if-alternative exp)
  (if (not (null? (cdddr exp)))
      (cadddr exp)
      'false))

(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

(define (begin? exp) (tagged-list? exp 'begin))
(define (begin-actions exp) (cdr exp))
(define (last-exp? seq) (null? (cdr seq)))
(define (first-exp seq) (car seq))
(define (rest-exps seq) (cdr seq))

(define (sequence->exp seq)
  (cond ((null? seq) seq)
	((last-exp? seq) (first-exp seq))
	(else (make-begin seq))))
(define (make-begin seq) (cons 'begin seq))

(define (application? exp) (pair? exp))
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))
(define (no-operands? ops) (null? ops))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))

(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))
(define (cond->if exp)
  (expand-clauses (cond-clauses exp)))
(define (expand-clauses clauses)
  (if (null? clauses)
      'false
      (let ((first (car clauses))
	    (rest (cdr clauses)))
	(if (cond-else-clause? first)
	    (if (null? rest)
		(sequence->exp (cond-actions first))
		(error "ELSE clause isn't last -- COND->IF"
		       clauses))
	    (make-if (cond-predicate first)
		     (sequence->exp (cond-actions first))
		     (expand-clauses rest))))))

(define (let? exp) (tagged-list? exp 'let))
(define (let-bindings exp) (cadr exp))
(define (let-variables exp) (map car (let-bindings exp)))
(define (let-exps      exp) (map cadr (let-bindings exp)))
(define (let-body exp) (cddr exp))
(define (let->combination exp)
  (cons (make-lambda (let-variables exp)
		     (let-body exp)) (let-exps exp)))
(define (make-procedure parameters body env)
  (list 'procedure parameters body env))
(define (compound-procedure? p)
  (tagged-list? p 'procedure))
(define (procedure-parameters p) (cadr p))
(define (procedure-body p) (scan-out-defines (caddr p)))
(define (procedure-environment p) (cadddr p))
(define (enclosing-environment env) (cdr env))
(define (first-frame env) (car env))
(define the-empty-environment '())
(define (make-frame variables values)
  (cons variables values))
(define (frame-variables frame) (car frame))
(define (frame-values frame) (cdr frame))
(define (add-bindings-to-frame! var val frame)
  (set-car! frame (cons var (car frame)))
  (set-cdr! frame (cons val (cdr frame))))
(define (extend-environment vars vals base-env)
  (if (= (length vars) (length vals))
      (cons (make-frame vars vals) base-env)
      (if (< (length vars) (length vals))
	  (error "Too many arguments supplied" vars vals)
	  (error "Too few arguments supplied" vars vals))))
(define (lookup-variable-value var env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
	     (env-loop (enclosing-environment env)))
	    ((eq? var (car vars))
	     (if (eq? (car vals) '*unassigned*)
		 (error "Unassigned variable" var)
	         (car vals)))
	    (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
	(error "Unbound variable" var)
	(let ((frame (first-frame env)))
	  (scan (frame-variables frame)
		(frame-values frame)))))
  (env-loop env))
(define (set-variable-value! var val env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars)
	     (env-loop (enclosing-environment env)))
	    ((eq? var (car vars))
	     (set-car! vals val))
	    (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
	(error "Unbound variable --SET!" var)
	(let ((frame (first-frame env)))
	  (scan (frame-variables frame)
		(frame-values frame)))))
  (env-loop env))
(define (define-variable! var val env)
  (let ((frame (first-frame env)))
    (define (scan vars vals)
      (cond ((null? vars)
	     (add-bindings-to-frame! var val frame))
	    ((eq? var (car vars))
	     (set-car! vals val))
	    (else (scan (cdr vars) (cdr vals)))))
    (scan (frame-variables frame)
	  (frame-values frame))))

(define (filter pred lst)
  (cond ((null? lst) '())
	((pred (car lst)) (cons (car lst) (filter pred (cdr lst))))
	(else (filter pred (cdr lst)))))

(define (make-let bindings body)
  (list 'let bindings body))
(define (make-let-binding var exp)
  (list var exp))

(define (scan-out-defines proc-body)
  (let ((defs (filter (lambda (exp) (tagged-list? exp 'define)) proc-body))
	(exps (filter (lambda (exp) (not (tagged-list? exp 'define))) proc-body)))
    (if (null? defs)
	exps
        (let ((vars (map definition-variable defs))
	      (vals (map definition-value    defs))
	      (assignments (map (lambda (x) (quote '*unassigned*)) defs)))
          (list (make-let (map make-let-binding vars assignments)
		    (append (map make-assignment vars vals)
				      exps)))))))
(define (true? x)
  (not (eq? x false)))
(define (false? x)
  (eq? x false))

(define lazy-car-primitive (list 'car (lambda (z) ((cadr z) (lambda (p q) p ))) 'strict))
(define lazy-cdr-primitive (list 'cdr (lambda (z) ((cadr z) (lambda (p q) q ))) 'strict))
(define primitive-procedures
  (list lazy-car-primitive
	lazy-cdr-primitive
	(list 'cons (lambda (x y) (list 'pair (lambda (m) (m x y)))) 'non-strict)
	(list 'list list 'non-strict)
	(list 'null? null? 'strict)
	(list '+ + 'strict)
	(list '- - 'strict)
	(list '* * 'strict)
	(list '/ / 'strict)
	(list '= = 'strict)
	(list 'exit exit 'strict)
	(list 'display display 'strict)
	; more primitives...
	))

(define (primitive-procedure-names)
  (map car primitive-procedures))
(define (primitive-procedure-objects)
  (map (lambda (proc) (list 'primitive (cadr proc) (caddr proc)))
       primitive-procedures))

(define (setup-environment)
  (let ((initial-env
	  (extend-environment (primitive-procedure-names)
			      (primitive-procedure-objects)
			      the-empty-environment)))
    (define-variable! 'true true initial-env)
    (define-variable! 'false false initial-env)
    initial-env))
(define the-global-environment (setup-environment))

(define (primitive-procedure? proc)
  (tagged-list? proc 'primitive))
(define (strict? proc)
  (eq? (caddr proc) 'strict))
(define (primitive-implementation proc) (cadr proc))

(define (apply-primitive-procedure proc args)
  (apply-in-underlying-scheme (primitive-implementation proc) args))

(define input-prompt ";;; M-Eval input:")
(define output-prompt ";;; M-Eval value:")
(define (driver-loop)
  (prompt-for-input input-prompt)
  (let ((input (read)))
    (let ((output (actual-value input the-global-environment)))
      (announce-output output-prompt)
      (user-print output)))
  (driver-loop))
(define (prompt-for-input string)
  (newline) (newline) (display string) (newline))
(define (announce-output string)
  (newline) (display string) (newline))

(define (cons? object)
  (tagged-list? object 'pair))
(define (lazy-list? object)
  (or (and (cons? object) (cons? (lazy-cdr object)))
      (and (cons? object) (null? (lazy-cdr object)))))
(define (lazy-car z)
  (actual-value (list 'car z) the-global-environment))
(define (lazy-cdr z)
  (actual-value (list 'cdr z) the-global-environment))

(define (print-lazy-list lst)
  (display "(")
  (display (lazy-car lst))
  (define (lazy-iter l sum)
    (cond ((= sum 10)
	   (display " ...)"))
	   ((null? l)
           (display ")"))
	  (else
	    (display " ")
	    (display (lazy-car l))
	    (lazy-iter (lazy-cdr l) (+ sum 1)))))
  (lazy-iter (lazy-cdr lst) 0))

(define (user-print object)
  (cond ((lazy-list? object)
	 (print-lazy-list object))
        ((cons? object)
	 (display "(")(display (lazy-car object))(display " . ")(display (lazy-cdr object))(display ")"))
	((compound-procedure? object)
         (display (list 'compound-procedure
		     (procedure-parameters object)
		     (procedure-body object)
		     '<procedure-env>)))
        (else (display object))))
(define the-global-environment (setup-environment))
(driver-loop)
