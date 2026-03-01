(set-logic UFDTLIA)

; datatypes
(declare-datatypes ((list 0)) (((nil) (cons (head Int) (tail list)))))
(declare-datatypes ((Pair 0)) (((Pair2 (first Bool) (second list)))))
; datatypes end

; functions declarations
(declare-fun insert2 (Int list) list)
(declare-fun isort (list) list)
(declare-fun bubble (list) Pair)
(declare-fun bubsort (list) list)
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
  (forall ((x list))
    (= (bubble x)
      (ite
        (is-cons x)
        (ite
          (is-cons (tail x))
          (ite
            (<= (head x) (head (tail x)))
            (let ((y (bubble (cons (head (tail x)) (tail (tail x))))))
              (Pair2 (first y) (cons (head x) (second y))))
            (Pair2 true
              (cons (head (tail x))
                (second (bubble (cons (head x) (tail (tail x))))))))
          (Pair2 false (cons (head x) nil)))
        (Pair2 false nil)))))
(assert
  (forall ((x list))
    (= (bubsort x)
      (let ((y (bubble x))) (ite (first y) (bubsort (second y)) x)))))
; functions declarations end

; proof goal
(assert (not (forall ((x list)) (= (bubsort x) (isort x)))))
; proof goal end

(check-sat)
