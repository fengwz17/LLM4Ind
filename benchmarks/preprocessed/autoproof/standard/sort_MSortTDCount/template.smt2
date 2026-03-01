(set-logic UFDTLIA)

; datatypes
(declare-datatypes ((list 0)) (((nil) (cons (head Int) (tail list)))))
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
; datatypes end

; functions declarations
(declare-fun ztake (Int list) list)
(declare-fun zlength (list) Int)
(declare-fun zdrop (Int list) list)
(declare-fun lmerge (list list) list)
(declare-fun msorttd (list) list)
(declare-fun count (Int list) Nat)
(assert
  (forall ((x Int) (y list))
    (= (ztake x y)
      (ite
        (= x 0) nil
        (ite (is-cons y) (cons (head y) (ztake (- x 1) (tail y))) nil)))))
(assert
  (forall ((x list))
    (= (zlength x) (ite (is-cons x) (+ 1 (zlength (tail x))) 0))))
(assert
  (forall ((x Int) (y list))
    (= (zdrop x y)
      (ite (= x 0) y (ite (is-cons y) (zdrop (- x 1) (tail y)) nil)))))
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
    (= (msorttd x)
      (ite
        (is-cons x)
        (ite
          (is-cons (tail x))
          (let
            ((k (div
                  (zlength (cons (head x) (cons (head (tail x)) (tail (tail x)))))
                  2)))
            (lmerge
              (msorttd
                (ztake k (cons (head x) (cons (head (tail x)) (tail (tail x))))))
              (msorttd
                (zdrop k (cons (head x) (cons (head (tail x)) (tail (tail x))))))))
          (cons (head x) nil))
        nil))))
(assert
  (forall ((x Int) (y list))
    (= (count x y)
      (ite
        (is-cons y)
        (ite (= x (head y)) (S (count x (tail y))) (count x (tail y)))
        Z))))
; functions declarations end

; proof goal
(assert (not (forall ((x Int) (y list)) (= (count x (msorttd y)) (count x y)))))
; proof goal end

(check-sat)
