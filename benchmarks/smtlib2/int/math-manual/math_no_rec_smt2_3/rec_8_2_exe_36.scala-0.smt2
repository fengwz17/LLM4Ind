(set-logic ALL)

(declare-fun sum_of_square (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (sum_of_square n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (sum_of_square n) 1) )))
(assert (forall ((n Int)) (=> (> n 1) (= (sum_of_square n) (+ (* n n) (sum_of_square (- n 1)))))))

(assert (not (forall ((n Int)) (=> (>= n 0) (= (sum_of_square n) (div (* n (+ n 1) (+ (* 2 n) 1)) 6) )))))
(check-sat)