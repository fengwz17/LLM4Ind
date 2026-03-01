(set-logic UFNIA)

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(assert (not (forall ((a Int) (i Int)) (=> (and (>= a 0) (>= i 0)) (= (div a (Pow2 (+ i 1))) (div (div a (Pow2 i)) 2)))) ))

(check-sat)
