(set-logic UFNIA)

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(declare-fun bitLength (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (bitLength x) 0))))
(assert (forall ((x Int)) (=> (> x 0) (= (bitLength x) (+ (bitLength (div x 2)) 1)))))

(assert (not (forall ((x Int) (y Int)) (=> (and (>= x 0) (>= y 0)) (= (- (+ (bitLength (Pow2 x)) (bitLength (Pow2 y))) 2) (- (bitLength (* (Pow2 x) (Pow2 y))) 1))))))

(check-sat)
