(set-logic UFDTLIA)
(declare-datatypes ((list 0)) (((nil) (cons (head Int) (tail list)))))
(declare-fun ssort_minimum (Int list) Int)
(declare-fun insert2 (Int list) list)
(declare-fun isort (list) list)
(declare-fun delete (Int list) list)
(declare-fun ssort (list) list)
(assert (not (forall ((x list)) (= (ssort x) (isort x)))))
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
(check-sat)
