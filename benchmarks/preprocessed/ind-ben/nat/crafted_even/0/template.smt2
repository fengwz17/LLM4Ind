(set-logic UFDT)

; datatypes
(declare-datatypes ((nat 0))
(((zero) (s (s0 nat)))))
; datatypes end

; functions declarations
(declare-fun add (nat nat) nat)
(declare-fun even (nat) Bool)
(assert (not (even (s zero))))
(assert (forall ((y nat)) (= (add zero y) y)))
(assert (forall ((x nat) (y nat)) (= (add (s x) y) (s (add x y)))))
(assert (even zero))
(assert (forall ((x nat)) (= (even (s (s x))) (even x))))
; functions declarations end

; proof goal
(assert (not (forall ((x nat) (y nat)) (=> (and (even x) (even y)) (even (add x y))) )))
; proof goal end

(check-sat)
