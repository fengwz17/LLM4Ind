(set-logic UFDT)
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun plus (Nat Nat) Nat)
(declare-fun mult (Nat Nat) Nat)
(declare-fun pow (Nat Nat) Nat)
(assert
  (not
    (forall ((x Nat) (y Nat) (z Nat))
      (= (pow x (plus y z)) (mult (pow x y) (pow x z))))))
(assert
  (forall ((x Nat) (y Nat))
    (= (plus x y) (ite (is-S x) (S (plus (p x) y)) y))))
(assert
  (forall ((x Nat) (y Nat))
    (= (mult x y) (ite (is-S x) (plus y (mult (p x) y)) Z))))
(assert
  (forall ((x Nat) (y Nat))
    (= (pow x y) (ite (is-S y) (mult x (pow x (p y))) (S Z)))))
(check-sat)
