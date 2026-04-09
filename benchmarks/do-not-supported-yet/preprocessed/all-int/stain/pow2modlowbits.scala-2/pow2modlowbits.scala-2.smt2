(set-logic UFNIA)

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(assert (not (forall ((c Int) (a Int) (b Int) (t Int)) (=> (and (<= 0 c) (>= a c) (>= b 0) (< b (Pow2 c)) (>= t 0)) (= (mod (+ (* t (Pow2 a)) b) (Pow2 c)) (mod b (Pow2 c)))) )))
(check-sat)
