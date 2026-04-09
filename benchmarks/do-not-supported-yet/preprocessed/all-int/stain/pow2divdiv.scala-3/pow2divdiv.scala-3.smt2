(set-logic UFNIA)

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(assert (not (forall ((x Int) (y Int) (a Int)) (=> (and (>= x 0) (>= y 0) (>= a 0)) (= (div (div a (Pow2 x)) (Pow2 y)) (div a (Pow2 (+ x y)))))) ))
(check-sat)
