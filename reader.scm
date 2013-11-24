(define (char-left-paren? ch) (char=? ch #\())
(define (char-right-paren? ch) (char=? ch #\)))
(define (char-comment? ch) (char=? ch #\;))
(define (char-string? ch) (char=? ch #\"))
(define (char-newline? ch) (char=? ch #\newline))
(define (char-dot? ch) (char=? ch #\.))
(define (char-quote? ch) (char=? ch #\'))
(define (char-backquote? ch) (char=? ch #\`))
(define (char-comma? ch) (char=? ch #\,))
(define (char-backslash? ch) (char=? ch #\\))
(define (char-character? ch) (char=? ch #\#))
(define (identifier-end? ch) (or (char-left-paren? ch)
                                 (char-right-paren? ch)
                                 (char-whitespace? ch)))

(define (read)
  (define ch (read-char))
  (cond ((char-left-paren? ch) (read-list))
        ((char-whitespace? ch) (read))
        ((char-comment? ch) (read-comment) (read))
        ((char-quote? ch) (cons 'quote (cons (read) '())))
        ((char-string? ch) (read-string))
        ((char-character? ch) (read-char-quote))
        ((char-numeric? ch) (read-number ch))
        (else (read-identifier ch))))

(define (read-char-quote)
  (read-char) (read-char))

(define (read-comment)
  (if (not (char-newline? (read-char)))
      (read-comment)))

(define (read-list)
  (define ch (read-char))
  (cond ((char-right-paren? ch) '())
        ((char-dot? ch) (car (read-list)))
        ((char-left-paren? ch) (cons (read-list)  (read-list)))
        ((char-whitespace? ch) (read-list))
        ((char-comment? ch) (read-comment) (read-list))
        ((char-quote? ch) (cons (cons 'quote (cons (read) '())) (read-list)))
        ((char-string? ch) (cons (read-string) (read-list)))
        ((char-character? ch) (read-char-quote))
        ((char-numeric? ch) (cons (read-number ch) (read-list)))
        (else (cons (read-identifier ch) (read-list)))))

(define (char-list->number lst)
  (string->number (list->string lst)))
   
(define (read-number ch)
  (define (read-nmb)
    (define peek (peek-char))
    (if (char-numeric? peek) 
        (cons (read-char) (read-nmb)) '()))
  (char-list->number (cons ch (read-nmb))))

(define (read-identifier ch)
  (define (read-id)
    (if (identifier-end? (peek-char)) '()
        (cons (read-char) (read-id))))
  (string->symbol (list->string (cons ch (read-id)))))
    
(define (interpret-escape ch)
   (cond ((char=? ch #\n) #\newline)          ;\n is newline
         ((char=? ch #\t) (integer->char 9))  ;\t is tab
         (else ch)))

(define (read-string)
  (define (read-str)
    (define ch (read-char))
    (cond ((char-backslash? ch) (cons (interpret-escape (read-char)) (read-str)))           
          ((char-string? ch) '())
          (else (cons ch (read-str)))))
  (list->string (read-str)))

(display (read))
(newline)
