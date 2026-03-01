(set-logic UFNIA)

; functions declarations
(declare-fun bitLength (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (bitLength x) 0))))
(assert (forall ((x Int)) (=> (> x 0) (= (bitLength x) (+ (bitLength (div x 2)) 1)))))
; functions declarations end

; proof goal
(assert (not (forall ((x Int)) (=> (>= x 0) (>= x (bitLength x))))))
; proof goal end

(check-sat)
