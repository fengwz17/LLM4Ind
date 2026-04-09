(set-logic ALL)

; functions declarations
(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))
; functions declarations end

; proof goal
(assert (not (forall ((a Int) (j Int)) (=> (and (>= a 0) (>= j 0)) (= (mod (* a (Pow2 j)) (Pow2 j)) 0))) ))
; proof goal end

(check-sat)
