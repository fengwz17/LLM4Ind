(set-logic ALL)
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (div n 2)) 1) ))))

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(assert (not (forall ((n Int) (k Int)) (=> (and (>= n 1) (>= k 0) (= n (Pow 2 k))) (= (f n) (+ k 1) )))))
(check-sat)