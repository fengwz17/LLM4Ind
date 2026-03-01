(set-logic ALL)
(declare-datatypes ((Nat 0)) (((Zero) (Succ (pred Nat)))))
(declare-datatypes ((Z 0)) ((Z (P (P_0 Nat)) (N (N_0 Nat)))))
(declare-fun plus (Nat Nat) Nat)
(declare-fun minus (Nat Nat) Z)
(declare-fun plus2 (Z Z) Z)
(assert
  (not
    (forall ((x Z) (y Z) (z Z))
      (= (plus2 x (plus2 y z)) (plus2 (plus2 x y) z)))))
(assert
  (forall ((x Nat) (y Nat))
    (= (plus x y) (ite (is-Succ x) (Succ (plus (pred x) y)) y))))
(assert
  (forall ((x Nat) (y Nat))
    (= (minus x y)
      (ite
        (is-Succ x)
        (ite (is-Succ y) (minus (pred x) (pred y)) (P (Succ (pred x))))
        (ite (is-Succ y) (N (pred y)) (P Zero))))))
(assert
  (forall ((x Z) (y Z))
    (= (plus2 x y)
      (ite
        (is-N x)
        (ite
          (is-N y) (N (Succ (plus (N_0 x) (N_0 y))))
          (minus (P_0 y) (Succ (N_0 x))))
        (ite
          (is-N y) (minus (P_0 x) (Succ (N_0 y)))
          (P (plus (P_0 x) (P_0 y))))))))
(check-sat)
