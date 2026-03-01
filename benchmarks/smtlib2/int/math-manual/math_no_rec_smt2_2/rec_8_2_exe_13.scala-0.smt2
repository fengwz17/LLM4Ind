(set-logic ALL)
(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 9))))
(assert (forall ((n Int)) (=> (= n 1) (= (a n) 10))))
(assert (forall ((n Int)) (=> (= n 2) (= (a n) 32))))
(assert (forall ((n Int)) (=> (> n 2) (= (a n) (+ (* 7 (a (- n 2))) (* 6 (a (- n 3))))  ))))

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(assert (not (forall ((n Int)) (=> (>= n 0) (= (a n) (+ (- (* 8 (Pow (- 1) n)) (* 3 (Pow (- 2) n))) (* 4 (Pow 3 n))) ) ))))
(check-sat)
