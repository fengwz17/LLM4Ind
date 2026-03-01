(set-logic UFNIA)

; functions declarations
(declare-fun isPow2 (Int) Bool)
(assert (forall ((x Int)) (=> (<= x 0) (= (isPow2 x) false))))
(assert (forall ((x Int)) (=> (= x 1) (= (isPow2 x) true))))
(assert (forall ((x Int)) (=> (and (> x 1) (= (mod x 2) 1)) (= (isPow2 x) false))))
(assert (forall ((x Int)) (=> (and (> x 1) (= (mod x 2) 0)) (= (isPow2 x) (isPow2 (div x 2))))))
; functions declarations end

; proof goal
(assert (not (forall ((x Int)) (=> (and (isPow2 x) (> x 1)) (isPow2 (div x 2)))) ))
; proof goal end

(check-sat)
