(set-logic UFDTLIA)

; datatypes
(declare-datatypes ((Nat 0)(Lst 0)) (((succ (pred Nat)) (zero))
((cons (head Nat) (tail Lst)) (nil))
))
; datatypes end

; functions declarations
(declare-fun append (Lst Lst) Lst)
(assert (forall ((x Lst)) (= (append nil x) x) ))
(assert (forall ((x Nat) (y Lst) (z Lst)) (= (append (cons x y) z) (cons x (append y z))) ))
(declare-fun rev (Lst) Lst)
(assert (= (rev nil) nil))
(assert (forall ((x Nat) (y Lst)) (= (rev (cons x y)) (append (rev y) (cons x nil))) ))
(declare-fun qreva (Lst Lst) Lst)
(assert (forall ((x Lst)) (= (qreva nil x) x) ))
(assert (forall ((x Lst) (y Lst) (z Nat)) (= (qreva (cons z x) y) (qreva x (cons z y))) ))
(declare-fun qrev (Lst) Lst)
(assert (forall ((x Lst)) (= (qrev x) (qreva x nil)) ))
; functions declarations end

; proof goal
(assert (not (forall ((x Lst) (y Lst) (z Lst)) (= (append (append x y) z) (append x (append y z))) )))
; proof goal end

(check-sat)
(exit)
