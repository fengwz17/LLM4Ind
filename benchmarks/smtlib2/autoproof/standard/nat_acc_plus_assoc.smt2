(set-logic UFDT)
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun acc_plus (Nat Nat) Nat)
(assert
  (not
    (forall ((x Nat) (y Nat) (z Nat))
      (= (acc_plus x (acc_plus y z)) (acc_plus (acc_plus x y) z)))))
(assert
  (forall ((x Nat) (y Nat))
    (= (acc_plus x y) (ite (is-S x) (acc_plus (p x) (S y)) y))))
(check-sat)
