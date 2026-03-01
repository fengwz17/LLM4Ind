(set-logic ALL)

; functions declarations
(declare-fun a (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (a n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (a n) 4))))
(assert (forall ((n Int)) (=> (> n 1) (= (a n) (* 4 (a (- n 2))) ))))
(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))
; functions declarations end

; proof goal
(assert (not (forall ((n Int)) (=> (>= n 0) (= (a n) (- (Pow 2 n) (Pow (- 2) n)) ) ))))
; proof goal end

(check-sat)
