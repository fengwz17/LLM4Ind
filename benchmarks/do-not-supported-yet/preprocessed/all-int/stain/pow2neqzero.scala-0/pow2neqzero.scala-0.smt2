(set-logic UFNIA)

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(assert (not (forall ((x Int)) (=> (>= x 0) (not (= (Pow2 x) 0)))) ))
(check-sat)
