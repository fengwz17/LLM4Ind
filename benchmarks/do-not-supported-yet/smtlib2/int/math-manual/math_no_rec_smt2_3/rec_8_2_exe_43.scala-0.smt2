(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)) )) ) ))

(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (a n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (a n) (+ (a (- n 1)) (a (- n 2)) 1) ) ) ))

(assert (not (forall ((n Int)) (=> (>= n 1) (= (a n) (- (+ (f (- n 1)) (* 2 (f n))) 1) )))))
(check-sat)