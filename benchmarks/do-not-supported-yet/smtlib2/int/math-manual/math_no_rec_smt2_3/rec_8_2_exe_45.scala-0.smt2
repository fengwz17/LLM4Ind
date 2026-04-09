(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 2))))
(assert (forall ((n Int)) (=> (= n 1) (= (a n) 6))))
(assert (forall ((n Int)) (=> (> n 1) (= (a n) (+ (* 3 (a (- n 1))) (* 4 (a (- n 2)))) ) ) ))

(assert (not (forall ((n Int)) (=> (>= n 1) (= (a n) (div (+ (Pow 4 (+ n 1)) (Pow (- 1) n)) 5))))))
(check-sat)