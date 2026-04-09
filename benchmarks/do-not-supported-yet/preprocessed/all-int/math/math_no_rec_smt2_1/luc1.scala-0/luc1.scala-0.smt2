(set-logic ALL)
(declare-fun l (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (l n) 2))))
(assert (forall ((n Int)) (=> (= n 1) (= (l n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (l n) (+ (l (- n 1)) (l (- n 2)))))))

(declare-fun Sigma_square_luc (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (Sigma_square_luc n) 4))))
(assert (forall ((n Int)) (=> (> n 0) (= (Sigma_square_luc n) (+ (* (l n) (l n)) (Sigma_square_luc (- n 1)))) )))

(assert (not (forall ((n Int)) (=> (>= n 0) (= (Sigma_square_luc n) (+ (* (l n) (l (+ 1 n))) 2)) ) ) ))
(check-sat)
