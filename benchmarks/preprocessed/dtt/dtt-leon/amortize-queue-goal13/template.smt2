(set-logic UFDTLIA)

; datatypes
(declare-datatypes ((Lst 0)) (((cons (head Int) (tail Lst)) (nil))))
(declare-datatypes ((Queue 0)) (((queue (front Lst) (back Lst)))))
; datatypes end

; functions declarations
(declare-fun less (Int Int) Bool)
(assert (forall ((x Int) (y Int)) (=> (and (>= x 0) (>= y 0)) (= (less x y) (< x y)))))
(define-fun leq ((x Int) (y Int)) Bool (<= x y))
(declare-fun plus (Int Int) Int)
(assert (forall ((n Int) (m Int)) (=> (and (>= n 0) (>= m 0)) (= (plus n m) (+ n m)))))
(declare-fun append (Lst Lst) Lst)
(assert (forall ((x Lst)) (= (append nil x) x)))
(assert (forall ((x Int) (y Lst) (z Lst)) (= (append (cons x y) z) (cons x (append y z)))))
(declare-fun len (Lst) Int)
(assert (= (len nil) 0))
(assert (forall ((x Int) (y Lst)) (= (len (cons x y)) (+ 1 (len y)))))
(assert (forall ((x Lst)) (>= (len x) 0)))
(declare-fun butlast (Lst) Lst)
(assert (= (butlast nil) nil))
(assert (forall ((x Int) (y Lst)) (= (butlast (cons x y)) (ite (= y nil) nil (cons x (butlast y))))))
(declare-fun qreva (Lst Lst) Lst)
(assert (forall ((x Lst)) (= (qreva nil x) x)))
(assert (forall ((x Lst) (y Lst) (z Int)) (= (qreva (cons z x) y) (qreva x (cons z y)))))
(declare-fun qrev (Lst) Lst)
(assert (forall ((x Lst)) (= (qrev x) (qreva x nil))))
(declare-fun queue-to-lst (Queue) Lst)
(assert (forall ((x Lst) (y Lst)) (= (queue-to-lst (queue x y)) (append x (qrev y)))))
(declare-fun qlen (Queue) Int)
(assert (forall ((x Lst) (y Lst)) (= (qlen (queue x y)) (plus (len x) (len y)))))
(assert (forall ((q Queue)) (>= (qlen q) 0)))
(declare-fun isAmortized (Queue) Bool)
(assert (forall ((x Lst) (y Lst)) (= (isAmortized (queue x y)) (leq (len y) (len x)))))
(declare-fun isEmpty (Queue) Bool)
(assert (forall ((x Lst) (y Lst)) (= (isEmpty (queue x y)) (and (= x nil) (= y nil)))))
(declare-fun amortizeQueue (Lst Lst) Queue)
(assert (forall ((x Lst) (y Lst)) (= (amortizeQueue x y) (ite (leq (len y) (len x)) (queue x y) (queue (append x (qrev y)) nil)))))
(declare-fun enqueue (Queue Int) Queue)
(assert (forall ((x Lst) (y Lst) (n Int)) (= (enqueue (queue x y) n) (amortizeQueue x (cons n y)))))
(declare-fun qpop (Queue) Queue)
(assert (forall ((x Lst) (y Lst) (n Int)) (= (qpop (queue x (cons n y))) (queue x y))))
(assert (forall ((x Lst)) (= (qpop (queue x nil)) (queue (butlast x) nil))))
; functions declarations end

; proof goal
(assert (not (forall ((x Lst) (y Lst)) (= (butlast (queue-to-lst (queue x y))) (queue-to-lst (qpop (queue x y))))) ))
; proof goal end

(check-sat)
