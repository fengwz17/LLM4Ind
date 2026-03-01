(set-logic UFDTLIA)
(declare-datatypes ((list 0)) (((nil) (cons (head Int) (tail list)))))
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun insert2 (Int list) list)
(declare-fun isort (list) list)
(declare-fun count (Int list) Nat)
(assert
  (not
    (forall ((x Int) (y list)) (= (count x (isort y)) (count x y)))))
(assert
  (forall ((x Int) (y list))
    (= (insert2 x y)
      (ite
        (is-cons y)
        (ite
          (<= x (head y)) (cons x (cons (head y) (tail y)))
          (cons (head y) (insert2 x (tail y))))
        (cons x nil)))))
(assert
  (forall ((x list))
    (= (isort x)
      (ite (is-cons x) (insert2 (head x) (isort (tail x))) nil))))
(assert
  (forall ((x Int) (y list))
    (= (count x y)
      (ite
        (is-cons y)
        (ite (= x (head y)) (S (count x (tail y))) (count x (tail y)))
        Z))))
(check-sat)
