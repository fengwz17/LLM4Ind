(set-logic UFNIA)

(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))

(declare-fun isPow2 (Int) Bool)
(assert (forall ((x Int)) (=> (<= x 0) (= (isPow2 x) false))))
(assert (forall ((x Int)) (=> (= x 1) (= (isPow2 x) true))))
(assert (forall ((x Int)) (=> (and (> x 1) (= (mod x 2) 1)) (= (isPow2 x) false))))
(assert (forall ((x Int)) (=> (and (> x 1) (= (mod x 2) 0)) (= (isPow2 x) (isPow2 (div x 2))))))

(assert (not (forall ((x Int) (y Int)) (=> (and (>= x 0) (>= y 0)) (isPow2 (* (Pow2 x) (Pow2 y))))) ))
(check-sat)
