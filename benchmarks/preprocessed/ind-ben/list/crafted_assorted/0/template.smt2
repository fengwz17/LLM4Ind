(set-logic UFDT)

; datatypes
(declare-datatypes ((nat 0) (lst 0)) (((zero) (s (s0 nat))) ((nil) (cons (cons0 nat) (cons1 lst)))))
; datatypes end

; functions declarations
(declare-fun add (nat nat) nat)
(declare-fun app (lst lst) lst)
(assert (forall ((y nat)) (= (add zero y) y)))
(assert (forall ((x nat) (y nat)) (= (add (s x) y) (s (add x y)))))
(assert (forall ((r lst)) (= (app nil r) r)))
(assert (forall ((a nat) (l lst) (r lst)) (= (app (cons a l) r) (cons a (app l r)))))
; functions declarations end

; proof goal
(assert (not (forall ((n nat) (x lst)) (= (app (cons (add n (s n)) x) (app x x)) (app (app (cons (add (s n) n) x) x) x)))))
; proof goal end

(check-sat)
