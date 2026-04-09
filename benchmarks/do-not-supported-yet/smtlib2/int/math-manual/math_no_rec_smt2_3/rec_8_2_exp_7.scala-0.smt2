(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 1))))
(assert (forall ((n Int)) (=> (= n 1) (= (a n) (- 2)))))
(assert (forall ((n Int)) (=> (= n 2) (= (a n) (- 1)))))
(assert (forall ((n Int)) (=> (> n 1) (= (a n) (- (- (* (- 3) (a (- n 1))) (* 3 (a (- n 2)))) (a (- n 3))) ) ) ))

(assert (not (forall ((n Int)) (=> (>= n 0) (= (a n) (* (- (+ 1 (* 3 n)) (* 2 n n)) (Pow (- 1) n)))))))
(check-sat)