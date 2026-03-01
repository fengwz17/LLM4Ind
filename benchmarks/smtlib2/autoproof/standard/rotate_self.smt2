(set-logic UFDT)
(declare-sort sk_a 0)
(declare-datatypes ((Nat 0)) ((Nat (S (p Nat)) (Z))))
(declare-datatypes ((List2 0))
  (((Cons (Cons_0 sk_a) (Cons_1 List2)) (Nil))))
(declare-fun append (List2 List2) List2)
(declare-fun rotate (Nat List2) List2)
(assert
  (not
    (forall ((n Nat) (xs List2))
      (= (rotate n (append xs xs))
        (append (rotate n xs) (rotate n xs))))))
(assert
  (forall ((x List2) (y List2))
    (= (append x y)
      (ite (is-Nil x) y (Cons (Cons_0 x) (append (Cons_1 x) y))))))
(assert
  (forall ((x Nat) (y List2))
    (= (rotate x y)
      (ite
        (is-Z x) y
        (ite
          (is-Nil y) Nil
          (rotate (p x) (append (Cons_1 y) (Cons (Cons_0 y) Nil))))))))
(check-sat)
