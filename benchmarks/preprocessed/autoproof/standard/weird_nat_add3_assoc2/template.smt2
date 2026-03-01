(set-logic UFDT)

; datatypes
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
; datatypes end

; functions declarations
(declare-fun add3 (Nat Nat Nat) Nat)
(assert
  (forall ((x Nat) (y Nat) (z Nat))
    (= (add3 x y z)
      (ite
        (is-S x) (S (add3 (p x) y z))
        (ite (is-S y) (S (add3 Z (p y) z)) z)))))
; functions declarations end

; proof goal
(assert (not (forall ((x1 Nat) (x2 Nat) (x3 Nat) (x4 Nat) (x5 Nat)) (= (add3 (add3 x1 x2 x3) x4 x5) (add3 x1 (add3 x2 x3 x4) x5)))))
; proof goal end

(check-sat)
