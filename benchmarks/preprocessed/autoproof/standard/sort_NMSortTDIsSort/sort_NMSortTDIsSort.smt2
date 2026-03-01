(set-logic UFDTLIA)
(declare-datatypes ((list 0)) (((nil) (cons (head Int) (tail list)))))
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-fun take (Nat list) list)
(declare-fun lmerge (list list) list)
(declare-fun length (list) Nat)
(declare-fun insert2 (Int list) list)
(declare-fun isort (list) list)
(declare-fun half (Nat) Nat)
(declare-fun drop (Nat list) list)
(declare-fun nmsorttd (list) list)
(assert (not (forall ((x list)) (= (nmsorttd x) (isort x)))))
(assert
  (forall ((x Nat) (y list))
    (= (take x y)
      (ite
        (is-S x)
        (ite (is-cons y) (cons (head y) (take (p x) (tail y))) nil) nil))))
(assert
  (forall ((x list) (y list))
    (= (lmerge x y)
      (ite
        (is-cons x)
        (ite
          (is-cons y)
          (ite
            (<= (head x) (head y))
            (cons (head x) (lmerge (tail x) (cons (head y) (tail y))))
            (cons (head y) (lmerge (cons (head x) (tail x)) (tail y))))
          (cons (head x) (tail x)))
        y))))
(assert
  (forall ((x list))
    (= (length x) (ite (is-cons x) (S (length (tail x))) Z))))
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
  (forall ((x Nat))
    (= (half x)
      (ite (is-S x) (ite (is-S (p x)) (S (half (p (p x)))) Z) Z))))
(assert
  (forall ((x Nat) (y list))
    (= (drop x y)
      (ite (is-S x) (ite (is-cons y) (drop (p x) (tail y)) nil) y))))
(assert
  (forall ((x list))
    (= (nmsorttd x)
      (ite
        (is-cons x)
        (ite
          (is-cons (tail x))
          (let
            ((k (half
                  (length (cons (head x) (cons (head (tail x)) (tail (tail x))))))))
            (lmerge
              (nmsorttd
                (take k (cons (head x) (cons (head (tail x)) (tail (tail x))))))
              (nmsorttd
                (drop k (cons (head x) (cons (head (tail x)) (tail (tail x))))))))
          (cons (head x) nil))
        nil))))
(check-sat)
