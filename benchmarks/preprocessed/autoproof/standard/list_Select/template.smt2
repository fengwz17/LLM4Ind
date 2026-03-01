(set-logic UFDT)
(declare-sort sk_t 0)
(declare-sort fun1 0)
; datatypes
(declare-datatypes ((list2 0))
  (((nil2) (cons2 (head2 sk_t) (tail2 list2)))))
(declare-datatypes ((Pair 0)) (((Pair2 (first sk_t) (second list2)))))
(declare-datatypes ((list 0))
  (((nil) (cons (head Pair) (tail list)))))
; datatypes end

; functions declarations
(declare-const lam fun1)
(declare-fun apply1 (fun1 Pair) sk_t)
(declare-fun select3 (sk_t list) list)
(declare-fun select2 (list2) list)
(declare-fun map2 (fun1 list) list2)
(declare-fun fst (Pair) sk_t)
(assert
  (forall ((x sk_t) (y list))
    (= (select3 x y)
      (ite
        (is-cons y)
        (cons (Pair2 (first (head y)) (cons2 x (second (head y))))
          (select3 x (tail y)))
        nil))))
(assert
  (forall ((x list2))
    (= (select2 x)
      (ite
        (is-cons2 x)
        (cons (Pair2 (head2 x) (tail2 x))
          (select3 (head2 x) (select2 (tail2 x))))
        nil))))
(assert
  (forall ((f fun1) (x list))
    (= (map2 f x)
      (ite
        (is-cons x) (cons2 (apply1 f (head x)) (map2 f (tail x))) nil2))))
(assert (forall ((x Pair)) (= (fst x) (first x))))
(assert (forall ((x Pair)) (= (apply1 lam x) (fst x))))
(check-sat)
; functions declarations end

; proof goal
(assert (not (forall ((xs list2)) (= (map2 lam (select2 xs)) xs))))
; proof goal end

