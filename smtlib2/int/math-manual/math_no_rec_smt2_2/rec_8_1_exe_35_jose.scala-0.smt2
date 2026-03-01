(set-logic ALL)
(declare-fun J (Int) Int)
(assert (forall ((n Int)) (=> (<= n 1) (= (J n) 1))))
(assert (forall ((n Int)) (=> (and (> n 1) (= (mod n 2) 0)) (= (J n) (- (* 2 (J (div n 2))) 1)) )))
(assert (forall ((n Int)) (=> (and (> n 1) (= (mod n 2) 1)) (= (J n) (+ (* 2 (J (div n 2))) 1)) )))

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(assert (not (forall ((m Int) (k Int)) (=> (and (>= m 0) (>= k 0) (< k (Pow2 m))) (= (J (+ (Pow2 m) k)) (+ (* 2 k) 1)) ) ) )) 
(check-sat)
