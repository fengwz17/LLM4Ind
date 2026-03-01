(set-logic ALL)
(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 1))))
(assert (forall ((n Int)) (=> (> n 0) (= (a n) (+ (* 2 (a (- n 1))) (* (* 2 n) n)) ))))

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(assert (not (forall ((n Int)) (=> (>= n 0) (= (a n) (- (- (- (* 13 (Pow 2 n)) (* (* 2 n) n)) (* 8 n)) 12) )))))
(check-sat)