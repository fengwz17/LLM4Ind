(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) (- 2)))))
(assert (forall ((n Int)) (=> (= n 1) (= (a n) 0) )))
(assert (forall ((n Int)) (=> (= n 2) (= (a n) 5))))
(assert (forall ((n Int)) (=> (> n 2) (= (a n) (+ (+ (- (* 7 (a (- n 1))) (* 16 (a (- n 2)))) (* 12 (a (- n 3)))) (* n (Pow 4 n))) ))))

(assert (not (forall ((n Int)) (=> (>= n 1) (= (a n) (+ (* 17 (Pow 2 n)) (* 39 n (Pow 2 (- n 1))) (* 61 (Pow 3 n)) (* (- (* 16 n) 80) (Pow 4 n))) )))))
(check-sat)