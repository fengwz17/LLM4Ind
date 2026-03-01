(set-logic ALL)

; functions declarations
(declare-fun sum_of_triangle (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (sum_of_triangle n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (sum_of_triangle n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (sum_of_triangle n) (+ (div (* n (+ n 1)) 2) (sum_of_triangle (- n 1))) )) ))
; functions declarations end

; proof goal
(assert (not (forall ((n Int)) (=> (>= n 0) (= (sum_of_triangle n) (div (* n (+ n 1) (+ n 2)) 6)) ))))
; proof goal end

(check-sat)
