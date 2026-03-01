(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun a (Int) Int)
(declare-fun b (Int) Int)

(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 1))))
(assert (forall ((n Int)) (=> (> n 0) (= (a n) (+ (* 3 (a (- n 1))) (* 2 (b (- n 1))))) )))


(assert (forall ((n Int)) (=> (<= n 0) (= (b n) 2))))
(assert (forall ((n Int)) (=> (> n 0) (= (b n) (+ (a (- n 1)) (* 2 (b (- n 1))))) )))


(assert (not (forall ((n Int)) (=> (>= n 0) (= (b n) (+ 1 (Pow 4 n)))))))
(check-sat)