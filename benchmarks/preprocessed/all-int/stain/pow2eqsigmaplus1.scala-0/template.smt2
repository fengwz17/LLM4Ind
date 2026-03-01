(set-logic UFNIA)

; functions declarations
(declare-fun Pow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (Pow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (Pow2 x) (* 2 (Pow2 (- x 1)))))))
(declare-fun SigmaPow2 (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (SigmaPow2 x) 1))))
(assert (forall ((x Int)) (=> (> x 0) (= (SigmaPow2 x) (+ (SigmaPow2 (- x 1)) (Pow2 x))))))
; functions declarations end

; proof goal
(assert (not (forall ((x Int)) (=> (>= x 0) (= (+ 1 (SigmaPow2 x)) (Pow2 (+ 1 x))))) ))
; proof goal end

(check-sat)
