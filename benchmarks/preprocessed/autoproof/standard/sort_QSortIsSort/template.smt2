(set-logic UFDTLIA)
(declare-sort fun1 0)
; datatypes
(declare-datatypes ((list 0)) (((nil) (cons (head Int) (tail list)))))
; datatypes end

; functions declarations
(declare-fun lam (Int) fun1)
(declare-fun lam2 (Int) fun1)
(declare-fun apply1 (fun1 Int) Bool)
(declare-fun insert2 (Int list) list)
(declare-fun isort (list) list)
(declare-fun filter (fun1 list) list)
(declare-fun append (list list) list)
(declare-fun qsort (list) list)
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
  (forall ((p fun1) (x list))
    (= (filter p x)
      (ite
        (is-cons x)
        (ite
          (apply1 p (head x)) (cons (head x) (filter p (tail x)))
          (filter p (tail x)))
        nil))))
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
; functions declarations end

; proof goal
(assert (not (forall ((x list)) (= (qsort x) (isort x)))))
; proof goal end

(check-sat)
