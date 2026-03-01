(set-logic UFDT)

; datatypes
(declare-datatypes ((nat 0)) (((zero) (s (s0 nat)))))
; datatypes end

; functions declarations
(declare-fun add (nat nat) nat)
(assert (forall ((y nat)) (= (add zero y) y)))
(assert (forall ((x nat) (y nat)) (= (add (s x) y) (s (add x y)))))
; functions declarations end

; proof goal
(assert (not (forall ((x nat) (y nat)) (= (add x y) (add y x)))))
; proof goal end

(check-sat)
