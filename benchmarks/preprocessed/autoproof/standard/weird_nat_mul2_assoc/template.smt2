(set-logic UFDT)

; datatypes
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
; datatypes end

; functions declarations
(declare-fun add3acc (Nat Nat Nat) Nat)
(declare-fun mul2 (Nat Nat) Nat)
(assert
  (forall ((x Nat) (y Nat) (z Nat))
    (= (add3acc x y z)
      (ite
        (is-S x) (add3acc (p x) (S y) z)
        (ite (is-S y) (add3acc Z (p y) (S z)) z)))))
(assert
  (forall ((x Nat) (y Nat))
    (= (mul2 x y)
      (ite
        (is-S x)
        (ite (is-S y) (S (add3acc (p x) (p y) (mul2 (p x) (p y)))) Z) Z))))
; functions declarations end

; proof goal
(assert (not (forall ((x Nat) (y Nat) (z Nat)) (= (mul2 x (mul2 y z)) (mul2 (mul2 x y) z)))))
; proof goal end

(check-sat)
