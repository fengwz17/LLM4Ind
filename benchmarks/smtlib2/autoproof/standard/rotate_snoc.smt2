(set-logic UFDT)
(declare-sort sk_a 0)
(declare-datatypes ((list 0))
  (((nil) (cons (head sk_a) (tail list)))))
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun snoc (sk_a list) list)
(declare-fun rotate (Nat list) list)
(declare-fun length (list) Nat)
(assert (not (forall ((xs list)) (= (rotate (length xs) xs) xs))))
(assert
  (forall ((x sk_a) (y list))
    (= (snoc x y)
      (ite (is-cons y) (cons (head y) (snoc x (tail y))) (cons x nil)))))
(assert
  (forall ((x Nat) (y list))
    (= (rotate x y)
      (ite
        (is-S x)
        (ite (is-cons y) (rotate (p x) (snoc (head y) (tail y))) nil) y))))
(assert
  (forall ((x list))
    (= (length x) (ite (is-cons x) (S (length (tail x))) Z))))
(check-sat)
