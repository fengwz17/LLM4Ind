(set-logic UFDTLIA)
(declare-datatypes ((list2 0))
  (((nil2) (cons2 (head2 Int) (tail2 list2)))))
(declare-datatypes ((list 0))
  (((nil) (cons (head list2) (tail list)))))
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun risers (list2) list)
(declare-fun lmerge (list2 list2) list2)
(declare-fun pairwise (list) list)
(declare-fun mergingbu2 (list) list2)
(declare-fun msortbu2 (list2) list2)
(declare-fun count (Int list2) Nat)
(assert
  (not
    (forall ((x Int) (y list2))
      (= (count x (msortbu2 y)) (count x y)))))
(assert
  (forall ((x list2))
    (= (risers x)
      (ite
        (is-cons2 x)
        (ite
          (is-cons2 (tail2 x))
          (ite
            (<= (head2 x) (head2 (tail2 x)))
            (let ((y (risers (cons2 (head2 (tail2 x)) (tail2 (tail2 x))))))
              (ite (is-cons y) (cons (cons2 (head2 x) (head y)) (tail y)) nil))
            (cons (cons2 (head2 x) nil2)
              (risers (cons2 (head2 (tail2 x)) (tail2 (tail2 x))))))
          (cons (cons2 (head2 x) nil2) nil))
        nil))))
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
    (= (mergingbu2 x)
      (ite
        (is-cons x)
        (ite
          (is-cons (tail x))
          (mergingbu2
            (pairwise (cons (head x) (cons (head (tail x)) (tail (tail x))))))
          (head x))
        nil2))))
(assert
  (forall ((x list2)) (= (msortbu2 x) (mergingbu2 (risers x)))))
(assert
  (forall ((x Int) (y list2))
    (= (count x y)
      (ite
        (is-cons2 y)
        (ite (= x (head2 y)) (S (count x (tail2 y))) (count x (tail2 y)))
        Z))))
(check-sat)
