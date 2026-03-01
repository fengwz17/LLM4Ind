(set-logic UFDTLIA)
(declare-sort fun1 0)
(declare-datatypes ((list 0)) (((nil) (cons (head Int) (tail list)))))
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun lam (Int) fun1)
(declare-fun lam2 (Int) fun1)
(declare-fun apply1 (fun1 Int) Bool)
(declare-fun filter (fun1 list) list)
(declare-fun count (Int list) Nat)
(declare-fun append (list list) list)
(declare-fun qsort (list) list)
(assert
  (not
    (forall ((x Int) (y list)) (= (count x (qsort y)) (count x y)))))
(assert
  (forall ((q fun1) (x list))
    (= (filter q x)
      (ite
        (is-cons x)
        (ite
          (apply1 q (head x)) (cons (head x) (filter q (tail x)))
          (filter q (tail x)))
        nil))))
(assert
  (forall ((x Int) (y list))
    (= (count x y)
      (ite
        (is-cons y)
        (ite (= x (head y)) (S (count x (tail y))) (count x (tail y)))
        Z))))
(assert
  (forall ((x list) (y list))
    (= (append x y)
      (ite (is-cons x) (cons (head x) (append (tail x) y)) y))))
(assert
  (forall ((x list))
    (= (qsort x)
      (ite
        (is-cons x)
        (append
          (append (qsort (filter (lam (head x)) (tail x)))
            (cons (head x) nil))
          (qsort (filter (lam2 (head x)) (tail x))))
        nil))))
(assert (forall ((y Int) (z Int)) (= (apply1 (lam y) z) (<= z y))))
(assert
  (forall ((y Int) (x2 Int)) (= (apply1 (lam2 y) x2) (> x2 y))))
(check-sat)
