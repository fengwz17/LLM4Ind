(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 1) (= (a n) 9))))
(assert (forall ((n Int)) (=> (> n 1) (= (a n) (+ (* 8 (a (- n 1))) (Pow 10 (- n 1)) )))))

(assert (not (forall ((n Int)) (=> (>= n 1) (= (a n) (div (+ (Pow 8 n) (Pow 10 n)) 2))))))
(check-sat)