(set-logic UFDTLIA)
(declare-datatypes ((list 0)) (((nil) (cons (head Int) (tail list)))))
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun ssort_minimum (Int list) Int)
(declare-fun delete (Int list) list)
(declare-fun ssort (list) list)
(declare-fun count (Int list) Nat)
(assert
  (not
    (forall ((x Int) (y list)) (= (count x (ssort y)) (count x y)))))
(assert
  (forall ((x Int) (y list))
    (= (ssort_minimum x y)
      (ite
        (is-cons y)
        (ite
          (<= (head y) x) (ssort_minimum (head y) (tail y))
          (ssort_minimum x (tail y)))
        x))))
(assert
  (forall ((x Int) (y list))
    (= (delete x y)
      (ite
        (is-cons y)
        (ite (= x (head y)) (tail y) (cons (head y) (delete x (tail y))))
        nil))))
(assert
  (forall ((x list))
    (= (ssort x)
      (ite
        (is-cons x)
        (let ((m (ssort_minimum (head x) (tail x))))
          (cons m (ssort (delete m (cons (head x) (tail x))))))
        nil))))
(assert
  (forall ((x Int) (y list))
    (= (count x y)
      (ite
        (is-cons y)
        (ite (= x (head y)) (S (count x (tail y))) (count x (tail y)))
        Z))))
(check-sat)
