(set-logic UFNIA)

(declare-fun bitLength (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (bitLength x) 0))))
(assert (forall ((x Int)) (=> (> x 0) (= (bitLength x) (+ (bitLength (div x 2)) 1)))))

(assert (not (forall ((x Int)) (=> (>= x 0) (>= x (bitLength x))))))
(check-sat)
