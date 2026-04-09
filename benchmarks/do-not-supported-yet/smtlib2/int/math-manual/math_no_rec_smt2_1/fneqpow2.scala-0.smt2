(set-logic ALL)
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (= n 2) (= (f n) 5))))
(assert (forall ((n Int)) (=> (> n 2) (= (f n) (- (* 3 (f (- n 1))) (* 2 (f (- n 2))))) ) ))

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(assert (not (forall ((x Int)) (=> (>= x 3) (= (f x) (- (Pow2 (+ x 1)) 3))) ) )) 
(check-sat)
