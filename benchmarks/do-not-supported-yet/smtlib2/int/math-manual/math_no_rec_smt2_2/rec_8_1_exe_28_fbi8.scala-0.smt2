(set-logic ALL)
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)))))))

(assert (not (forall ((n Int)) (=> (>= n 5) (= (f n) (+ (* 5 (f (- n 4))) (* 3 (f (- n 5))))) ) ) )) 
(check-sat)
