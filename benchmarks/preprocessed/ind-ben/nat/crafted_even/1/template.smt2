(set-logic UFDT)

; datatypes
(declare-datatypes ((nat 0))
(((zero) (s (s0 nat)))))
; datatypes end

; functions declarations
(declare-fun add (nat nat) nat)
(declare-fun even (nat) Bool)
(declare-fun mul (nat nat) nat)
(assert (not (even (s zero))))
(assert (forall ((y nat)) (= (add zero y) y)))
(assert (forall ((x nat) (y nat)) (= (add (s x) y) (s (add x y)))))
(assert (even zero))
(assert (forall ((x nat)) (= (even (s (s x))) (even x))))
(assert (forall ((y nat)) (= (mul zero y) zero)))
(assert (forall ((x nat) (y nat)) (= (mul (s x) y) (add (mul x y) y))))
; functions declarations end

; proof goal
(assert (not (forall ((x nat) (y nat)) (=> (or (even x) (even y)) (even (mul x y))) )))
; proof goal end

(check-sat)
