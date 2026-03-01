(set-logic UFDTLIA)

; datatypes
(declare-datatypes ((Lst 0)(Nat 0)) (((cons (head Nat) (tail Lst)) (nil))
((succ (pred Nat)) (zero))
))
; datatypes end

; functions declarations
(declare-fun len (Lst) Nat)
(assert (= (len nil) zero))
(assert (forall ((x Nat) (y Lst)) (= (len (cons x y)) (succ (len y))) ))
(declare-fun append (Lst Lst) Lst)
(assert (forall ((x Lst)) (= (append nil x) x) ))
(assert (forall ((x Nat) (y Lst) (z Lst)) (= (append (cons x y) z) (cons x (append y z))) ))
(declare-fun rotate (Nat Lst) Lst)
(assert (forall ((x Lst)) (= (rotate zero x) x) ))
(assert (forall ((n Nat)) (= (rotate (succ n) nil) nil) ))
(assert (forall ((n Nat) (y Nat) (x Lst)) (= (rotate (succ n) (cons y x)) (rotate n (append x (cons y nil)))) ))
(declare-fun plus (Nat Nat) Nat)
(assert (forall ((n Nat)) (= (plus zero n) n) ))
(assert (forall ((n Nat) (m Nat)) (= (plus (succ n) m) (succ (plus n m))) ))
; functions declarations end

; proof goal
(assert (not (forall ((x Lst) (y Lst)) (= (len (append x y)) (len (append y x))) )))
; proof goal end

(check-sat)
(exit)
