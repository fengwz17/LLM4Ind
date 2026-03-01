(set-logic UFDTLIA)
(declare-sort fun1 0)
(declare-datatypes ((list2 0))
  (((nil2) (cons2 (head2 Int) (tail2 list2)))))
(declare-datatypes ((list 0))
  (((nil) (cons (head list2) (tail list)))))
(declare-const lam fun1)
(declare-fun apply1 (fun1 Int) list2)
(declare-fun map2 (fun1 list2) list)
(declare-fun lmerge (list2 list2) list2)
(declare-fun pairwise (list) list)
(declare-fun mergingbu (list) list2)
(declare-fun msortbu (list2) list2)
(declare-fun insert2 (Int list2) list2)
(declare-fun isort (list2) list2)
(assert (not (forall ((x list2)) (= (msortbu x) (isort x)))))
(assert
  (forall ((f fun1) (x list2))
    (= (map2 f x)
      (ite
        (is-cons2 x) (cons (apply1 f (head2 x)) (map2 f (tail2 x))) nil))))
(assert
  (forall ((x list2) (y list2))
    (= (lmerge x y)
      (ite
        (is-cons2 x)
        (ite
          (is-cons2 y)
          (ite
            (<= (head2 x) (head2 y))
            (cons2 (head2 x) (lmerge (tail2 x) (cons2 (head2 y) (tail2 y))))
            (cons2 (head2 y) (lmerge (cons2 (head2 x) (tail2 x)) (tail2 y))))
          (cons2 (head2 x) (tail2 x)))
        y))))
(assert
  (forall ((x list))
    (= (pairwise x)
      (ite
        (is-cons x)
        (ite
          (is-cons (tail x))
          (cons (lmerge (head x) (head (tail x))) (pairwise (tail (tail x))))
          (cons (head x) nil))
        nil))))
(assert
  (forall ((x list))
    (= (mergingbu x)
      (ite
        (is-cons x)
        (ite
          (is-cons (tail x))
          (mergingbu
            (pairwise (cons (head x) (cons (head (tail x)) (tail (tail x))))))
          (head x))
        nil2))))
(assert
  (forall ((x list2)) (= (msortbu x) (mergingbu (map2 lam x)))))
(assert
  (forall ((x Int) (y list2))
    (= (insert2 x y)
      (ite
        (is-cons2 y)
        (ite
          (<= x (head2 y)) (cons2 x (cons2 (head2 y) (tail2 y)))
          (cons2 (head2 y) (insert2 x (tail2 y))))
        (cons2 x nil2)))))
(assert
  (forall ((x list2))
    (= (isort x)
      (ite (is-cons2 x) (insert2 (head2 x) (isort (tail2 x))) nil2))))
(assert (forall ((y Int)) (= (apply1 lam y) (cons2 y nil2))))
(check-sat)
