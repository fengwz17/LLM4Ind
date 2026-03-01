(set-logic ALL)
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)))))))

(assert (not (forall ((n Int)) (=> (and (>= n 1) (= (mod n 5) 0)) (= (mod (f n) 5) 0) ) ) )) 
(check-sat)
