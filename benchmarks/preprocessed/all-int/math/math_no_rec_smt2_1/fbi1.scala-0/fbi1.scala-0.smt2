(set-logic ALL)
; fbi: f(n) = f(n - 1) + f(n - 2) for n > 1, f(0) = 0, f(1) = 1
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)))))))
; Sigma_odd: Sigma_odd(n) = f(2n - 1) + Sigma_odd(n - 1) for n > 0, Sigma_odd(0) = 0
(declare-fun Sigma_odd (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (Sigma_odd n) 0))))
(assert (forall ((n Int)) (=> (> n 0) (= (Sigma_odd n) (+ (f (- (* 2 n) 1)) (Sigma_odd (- n 1)))) )))


(assert (not (forall ((n Int)) (=> (>= n 1) (= (Sigma_odd n) (f (* 2 n))) ) ) ))
(check-sat)
