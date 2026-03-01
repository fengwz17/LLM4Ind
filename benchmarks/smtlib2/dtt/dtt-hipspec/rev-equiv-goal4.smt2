(set-logic UFDTLIA)

(declare-datatypes ((Lst 0)) (((cons (head Int) (tail Lst)) (nil))))
;(set-logic ALL_SUPPORTED)


(declare-fun append (Lst Lst) Lst)
(assert (forall ((x Lst)) (= (append nil x) x)))
(assert (forall ((x Int) (y Lst) (z Lst)) (= (append (cons x y) z) (cons x (append y z)))))

(declare-fun rev (Lst) Lst)
(assert (= (rev nil) nil))
(assert (forall ((x Int) (y Lst)) (= (rev (cons x y)) (append (rev y) (cons x nil)))))

(declare-fun qreva (Lst Lst) Lst)
(assert (forall ((x Lst)) (= (qreva nil x) x)))
(assert (forall ((x Lst) (y Lst) (z Int)) (= (qreva (cons z x) y) (qreva x (cons z y)))))

(declare-fun qrev (Lst) Lst)
(assert (forall ((x Lst)) (= (qrev x) (qreva x nil))))


; proven
; conjecture
(assert (not 
(forall ((x Lst) (y Lst)) (= (qreva (qreva x y) nil) (qreva y x)))  ; G-rev-equiv-4 
))
(check-sat)
