(set-logic ALL)
; fbi: f(n) = f(n - 1) + f(n - 2) for n > 1, f(0) = 0, f(1) = 1
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)))))))
(declare-fun Sigma_con (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (Sigma_con n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (Sigma_con n) (+ (* (f 0) (f 1)) (* (f 1) (f 2)))))))
(assert (forall ((n Int)) (=> (> n 1) (= (Sigma_con n) (+ (+ (* (f (- (* 2 n) 2)) (f (- (* 2 n) 1))) (* (f (- (* 2 n) 1)) (f (* 2 n)))) (Sigma_con (- n 1))) ) )))

(assert (not (forall ((n Int)) (=> (>= n 1) (= (Sigma_con n) (* (f (* 2 n)) (f (* 2 n))) ) )) ))
(check-sat)
