(set-logic UFNIA)

; functions declarations
(declare-fun bitLength (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (bitLength x) 0))))
(assert (forall ((x Int)) (=> (> x 0) (= (bitLength x) (+ (bitLength (div x 2)) 1)))))
(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))
; functions declarations end

; proof goal
(assert (not (forall ((x Int)) (=> (>= x 0) (= x (bitLength (- (Pow2 x) 1)))))))
; proof goal end

(check-sat)
