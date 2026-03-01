(set-logic ALL)

; functions declarations
(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 4))))
(assert (forall ((n Int)) (=> (= n 1) (= (a n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (a n) (- (* 2 (a (- n 1))) (a (- n 2)) ) ))))
; functions declarations end

; proof goal
(assert (not (forall ((n Int)) (=> (>= n 0) (= (a n) (- 4 (* 3 n)) ) ))))
; proof goal end

(check-sat)
