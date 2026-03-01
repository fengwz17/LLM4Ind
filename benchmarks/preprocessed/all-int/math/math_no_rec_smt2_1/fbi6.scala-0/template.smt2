(set-logic ALL)

; functions declarations
(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)))))))
; functions declarations end

; proof goal
(assert (not (forall ((n Int)) (=> (and (>= n 1) (= (mod n 4) 0)) (= (mod (f n) 3) 0))) ))
; proof goal end

(check-sat)
