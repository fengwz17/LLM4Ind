(set-logic ALL)
; fbi: f(n) = f(n - 1) + f(n - 2) for n > 1, f(0) = 0, f(1) = 1
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)))))))

(declare-fun Sigma_minus_add (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (Sigma_minus_add n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (Sigma_minus_add n) (+ (- (f 0) (f 1)) (f 2))) )) )
(assert (forall ((n Int)) (=> (> n 1) (= (Sigma_minus_add n) (+ (- (Sigma_minus_add (- n 1)) (f (- (* 2 n) 1))) (f (* 2 n))) ) )))

(assert (not (forall ((n Int)) (=> (>= n 1) (= (Sigma_minus_add n) (- (f (- (* 2 n) 1)) 1))) ) ))
(check-sat)
