(set-logic ALL)
(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun a (Int Int) Int)
(assert (forall ((n Int) (alpha Int)) (=> (<= n 0) (= (a n alpha) alpha))))
(assert (forall ((n Int) (alpha Int)) (=> (> n 0) (= (a n alpha) (+ (* 2 (a (- n 1) alpha)) (* 3 (Pow 2 n))) ))))

(assert (not (forall ((n Int) (alpha Int)) (=> (>= n 0) (= (a n alpha) (* (+ alpha (* 3 n)) (Pow 2 n)))))))
(check-sat)