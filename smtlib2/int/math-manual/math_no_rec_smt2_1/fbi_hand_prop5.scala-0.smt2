(set-logic ALL)
; fbi: f(n) = f(n - 1) + f(n - 2) for n > 1, f(0) = 0, f(1) = 1
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)))))))

(assert (not (forall ((n Int)) (=> (>= n 3) (= (f n) (+ (* 2 (f (- n 2))) (f (- n 3)))))) ))
(check-sat)
