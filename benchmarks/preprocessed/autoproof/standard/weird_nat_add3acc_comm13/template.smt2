(set-logic UFDT)

; datatypes
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
; datatypes end

; functions declarations
(declare-fun add3acc (Nat Nat Nat) Nat)
(assert
  (forall ((x Nat) (y Nat) (z Nat))
    (= (add3acc x y z)
      (ite
        (is-S x) (add3acc (p x) (S y) z)
        (ite (is-S y) (add3acc Z (p y) (S z)) z)))))
; functions declarations end

; proof goal
(assert (not (forall ((x Nat) (y Nat) (z Nat)) (= (add3acc x y z) (add3acc z y x)))))
; proof goal end

(check-sat)
