(set-logic ALL)
(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 4))))
(assert (forall ((n Int)) (=> (= n 1) (= (a n) 10))))
(assert (forall ((n Int)) (=> (> n 1) (= (a n) (- (* 6 (a (- n 1))) (* 8 (a (- n 2))) ) ))))

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(assert (not (forall ((n Int)) (=> (>= n 0) (= (a n) (+ (* 3 (Pow 2 n)) (Pow 4 n)) ) ))))
(check-sat)
