(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) (- 1)))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (* 5 (f (div n 4))) (* 6 n))) ) ))

(assert (not (forall ((n Int) (k Int)) (=> (and (>= k 0) (= n (Pow 4 k))) (= (f n) (+ (* (- 24) n) (Pow 5 (+ k 2))))))))
(check-sat)