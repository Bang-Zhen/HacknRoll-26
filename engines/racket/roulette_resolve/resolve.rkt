#lang racket

(require json)

(define input (read-json))

(define bet (hash-ref input 'bet))
(define result (hash-ref input 'result))
(define amount-minor (hash-ref input 'amountMinor))

(define bet-type (hash-ref bet 'betType))
(define selection (hash-ref bet 'selection #f))
(define winning-number (hash-ref result 'winningNumber))
(define color (hash-ref result 'color))

(define (resolve)
  (cond
    [(equal? bet-type "straight")
     (define won (and selection (equal? winning-number selection)))
     (values won (if won (* amount-minor 36) 0))]
    [(or (equal? bet-type "red") (equal? bet-type "black"))
     (define won (equal? color bet-type))
     (values won (if won (* amount-minor 2) 0))]
    [(equal? bet-type "green")
     (define won (equal? color "green"))
     (values won (if won (* amount-minor 14) 0))]
    [else (values #f 0)]))

(define-values (won payout) (resolve))
(write-json (hash 'won won 'payoutMinor payout))
