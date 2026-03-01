(set-logic ALL)

; functions declarations
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)))))))
; Sigma_square: Sigma_square(n) = f(n)^2 + Sigma_square(n - 1) for n > 0, Sigma_square(0) = 0
(declare-fun Sigma_square (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (Sigma_square n) 0))))
(assert (forall ((n Int)) (=> (> n 0) (= (Sigma_square n) (+ (* (f n) (f n)) (Sigma_square (- n 1)))) )))
; functions declarations end

; proof goal
(assert (not (forall ((x Int)) (=> (>= x 1) (= (Sigma_square x) (* (f x) (f (+ 1 x))))) ) ))
; proof goal end

(check-sat)
