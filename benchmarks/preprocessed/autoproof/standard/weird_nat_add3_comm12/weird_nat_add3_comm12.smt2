(set-logic UFDT)
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun add3 (Nat Nat Nat) Nat)
(assert
  (not
    (forall ((x Nat) (y Nat) (z Nat)) (= (add3 x y z) (add3 y x z)))))
(assert
  (forall ((x Nat) (y Nat) (z Nat))
    (= (add3 x y z)
      (ite
        (is-S x) (S (add3 (p x) y z))
        (ite (is-S y) (S (add3 Z (p y) z)) z)))))
(check-sat)
