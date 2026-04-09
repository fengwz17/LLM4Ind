(set-logic UFNIA)

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(assert (not (forall ((b Int) (c Int)) (=> (and (>= b 0) (<= b c)) (>= (Pow2 c) (Pow2 b)))) ))
(check-sat)
