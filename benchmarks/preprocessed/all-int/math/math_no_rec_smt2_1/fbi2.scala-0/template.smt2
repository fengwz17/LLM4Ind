(set-logic ALL)

; functions declarations
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)))))))
(declare-fun PowNeg1 (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (PowNeg1 n) 1))))
(assert (forall ((n Int)) (=> (> n 0) (= (PowNeg1 n) (* (- 1) (PowNeg1 (- n 1)))))))
; functions declarations end

; proof goal
(assert (not (forall ((n Int)) (=> (>= n 1) (= (PowNeg1 n) (- (* (f (+ n 1)) (f (- n 1))) (* (f n) (f n)))) )) ))
; proof goal end

(check-sat)
