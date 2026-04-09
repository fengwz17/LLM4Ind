(set-logic ALL)
(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 5))))
(assert (forall ((n Int)) (=> (= n 1) (= (a n) (- 9)))))
(assert (forall ((n Int)) (=> (= n 2) (= (a n) 15))))
(assert (forall ((n Int)) (=> (> n 2) (= (a n) (- (- (* (- 3) (a (- n 1))) (* 3 (a (- n 2)))) (a (- n 3))) ))))

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(assert (not (forall ((n Int)) (=> (>= n 1) (= (a n) (* (+ (+ (* n n) (* 3 n)) 5) (Pow (- 1) n)) )))))
(check-sat)
