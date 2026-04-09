(set-logic ALL)

; functions declarations
(declare-fun M (Int) Int)
(assert (forall ((n Int)) (=> (<= n 100) (= (M n) (M (M (+ n 11))) ) )))
(assert (forall ((n Int)) (=> (> n 100) (= (M n) (- n 10) )) ))
; functions declarations end

; proof goal
(assert (not (forall ((n Int)) (=> (and (>= n 1) (<= n 101)) (= (M n) 91) ) )))
; proof goal end

(check-sat)
