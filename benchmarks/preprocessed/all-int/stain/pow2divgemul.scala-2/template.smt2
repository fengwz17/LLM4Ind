(set-logic UFNIA)

; functions declarations
(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))
; functions declarations end

; proof goal
(assert (not (forall ((x Int) (y Int) (a Int)) (=> (and (>= x 0) (>= y 0) (>= a 0) (<= x y)) (>= (div a (Pow2 x)) (* (div a (Pow2 y)) (Pow2 (- y x))))) )))
; proof goal end

(check-sat)
