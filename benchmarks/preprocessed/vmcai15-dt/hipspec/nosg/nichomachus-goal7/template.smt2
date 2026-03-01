(set-logic UFDTLIA)

; datatypes
(declare-datatypes ((Nat 0)) (((succ (pred Nat)) (zero))
))
; datatypes end

; functions declarations
(declare-fun plus (Nat Nat) Nat)
(assert (forall ((n Nat)) (= (plus zero n) n) ))
(assert (forall ((n Nat) (m Nat)) (= (plus (succ n) m) (succ (plus n m))) ))
(declare-fun mult (Nat Nat) Nat)
(assert (forall ((n Nat)) (= (mult zero n) zero) ))
(assert (forall ((n Nat) (m Nat)) (= (mult (succ n) m) (plus (mult n m) m)) ))
(declare-fun tri (Nat) Nat)
(assert (= (tri zero) zero))
(assert (forall ((n Nat)) (= (tri (succ n)) (plus (tri n) (succ n))) ))
(declare-fun cubes (Nat) Nat)
(assert (= (cubes zero) zero))
(assert (forall ((n Nat)) (= (cubes (succ n)) (plus (cubes n) (mult (succ n) (mult (succ n) (succ n))))) ))
; functions declarations end

; proof goal
(assert (not (forall ((x Nat) (y Nat)) (= (mult (tri x) (plus y y)) (mult x (mult y (succ x)))) )))
; proof goal end

(check-sat)
(exit)
