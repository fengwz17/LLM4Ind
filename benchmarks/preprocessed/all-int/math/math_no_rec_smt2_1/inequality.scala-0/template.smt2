(set-logic ALL)

; functions declarations
(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))
; functions declarations end

; proof goal
(assert (not (forall ((a Int) (b Int) (c Int) (n Int)) (=> (and (>= a 1) (>= b 1) (>= c 1) (>= n 3) (= (* c c) (+ (* a a) (* b b))) ) (< (+ (Pow a n) (Pow b n)) (Pow c n))) ) ))
; proof goal end

(check-sat)
