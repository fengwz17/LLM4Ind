(set-logic UFDT)

; datatypes
(declare-datatypes ((nat 0)) (((zero) (s (s0 nat)))))
; datatypes end

; functions declarations
(declare-fun add (nat nat) nat)
(declare-fun dup (nat) nat)
(assert (forall ((y nat)) (= (add zero y) y)))
(assert (forall ((x nat) (y nat)) (= (add (s x) y) (s (add x y)))))
(assert (= (dup zero) zero))
(assert (forall ((x nat)) (= (dup (s x)) (s (s (dup x))))))
; functions declarations end

; proof goal
(assert (not (forall ((v0 nat)) (= (dup v0) (add v0 v0)))))
; proof goal end

(check-sat)
