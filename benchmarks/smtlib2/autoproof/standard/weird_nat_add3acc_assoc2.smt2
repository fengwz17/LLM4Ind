(set-logic UFDT)
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun add3acc (Nat Nat Nat) Nat)
(assert
  (not
    (forall ((x1 Nat) (x2 Nat) (x3 Nat) (x4 Nat) (x5 Nat))
      (= (add3acc (add3acc x1 x2 x3) x4 x5)
        (add3acc x1 (add3acc x2 x3 x4) x5)))))
(assert
  (forall ((x Nat) (y Nat) (z Nat))
    (= (add3acc x y z)
      (ite
        (is-S x) (add3acc (p x) (S y) z)
        (ite (is-S y) (add3acc Z (p y) (S z)) z)))))
(check-sat)
