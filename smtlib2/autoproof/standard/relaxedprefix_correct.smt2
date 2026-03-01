(set-logic UFDT)
(declare-datatypes ((list3 0))
  ((list3 (nil3) (cons3 (head3 Bool) (tail3 list3)))))
(declare-datatypes ((It 0)) (((A) (B) (C))))
(declare-datatypes ((list2 0))
  (((nil2) (cons2 (head2 It) (tail2 list2)))))
(declare-datatypes ((list 0))
  (((nil) (cons (head list2) (tail list)))))
(declare-fun removeOne2 (It list) list)
(declare-fun removeOne (list2) list)
(declare-fun or2 (list3) Bool)
(declare-fun eq (It It) Bool)
(declare-fun isPrefix (list2 list2) Bool)
(declare-fun spec2 (list2 list) list3)
(declare-fun spec (list2 list2) Bool)
(declare-fun isRelaxedPrefix (list2 list2) Bool)
(assert
  (not
    (forall ((xs list2) (ys list2))
      (= (isRelaxedPrefix xs ys) (spec xs ys)))))
(assert
  (forall ((x It) (y list))
    (= (removeOne2 x y)
      (ite
        (is-cons y) (cons (cons2 x (head y)) (removeOne2 x (tail y)))
        nil))))
(assert
  (forall ((x list2))
    (= (removeOne x)
      (ite
        (is-cons2 x)
        (cons (tail2 x) (removeOne2 (head2 x) (removeOne (tail2 x))))
        nil))))
(assert
  (forall ((x list3))
    (= (or2 x)
      (ite (is-cons3 x) (or (head3 x) (or2 (tail3 x))) false))))
(assert
  (forall ((x It) (y It))
    (= (eq x y)
      (ite (is-C x) (is-C y) (ite (is-B x) (is-B y) (is-A y))))))
(assert
  (forall ((x list2) (y list2))
    (= (isPrefix x y)
      (ite
        (is-cons2 x)
        (ite
          (is-cons2 y)
          (and (eq (head2 x) (head2 y)) (isPrefix (tail2 x) (tail2 y)))
          false)
        true))))
(assert
  (forall ((ys list2) (x list))
    (= (spec2 ys x)
      (ite
        (is-cons x) (cons3 (isPrefix (head x) ys) (spec2 ys (tail x)))
        nil3))))
(assert
  (forall ((x list2) (y list2))
    (= (spec x y) (or2 (spec2 y (cons x (removeOne x)))))))
(assert
  (forall ((x list2) (y list2))
    (= (isRelaxedPrefix x y)
      (ite
        (is-cons2 x)
        (ite
          (is-cons2 (tail2 x))
          (ite
            (is-cons2 y)
            (ite
              (eq (head2 x) (head2 y))
              (isRelaxedPrefix (cons2 (head2 (tail2 x)) (tail2 (tail2 x)))
                (tail2 y))
              (isPrefix (cons2 (head2 (tail2 x)) (tail2 (tail2 x)))
                (cons2 (head2 y) (tail2 y))))
            false)
          true)
        true))))
(check-sat)
