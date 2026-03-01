(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (* 5 (f (- n 1))) (* 6 (Pow 4 n)))) ) ))

(assert (not (forall ((k Int)) (=> (>= k 0) (= (f k) (+ (* (- 24) (Pow 4 k)) (Pow 5 (+ k 2))))))))
(check-sat)