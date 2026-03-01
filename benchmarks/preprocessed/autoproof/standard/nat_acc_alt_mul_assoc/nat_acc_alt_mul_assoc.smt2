(set-logic UFDT)
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun acc_plus (Nat Nat) Nat)
(declare-fun acc_alt_mul (Nat Nat) Nat)
(assert
  (not
    (forall ((x Nat) (y Nat) (z Nat))
      (= (acc_alt_mul x (acc_alt_mul y z))
        (acc_alt_mul (acc_alt_mul x y) z)))))
(assert
  (forall ((x Nat) (y Nat))
    (= (acc_plus x y) (ite (is-S x) (acc_plus (p x) (S y)) y))))
(assert
  (forall ((x Nat) (y Nat))
    (= (acc_alt_mul x y)
      (ite
        (is-S x)
        (ite
          (is-S y)
          (S (acc_plus (p x) (acc_plus (p y) (acc_alt_mul (p x) (p y))))) Z)
        Z))))
(check-sat)
