(set-logic UFDT)

; datatypes
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
; datatypes end

; functions declarations
(declare-fun op (Nat Nat Nat Nat) Nat)
(assert
  (forall ((x Nat) (y Nat) (z Nat) (x2 Nat))
    (= (op x y z x2)
      (ite
        (is-S x)
        (ite (is-S z) (op (S (p x)) y (p z) (S x2)) (op (p x) y y x2))
        (ite (is-S z) (op Z y (p z) (S x2)) x2)))))
; functions declarations end

; proof goal
(assert (not (forall ((a Nat) (b Nat) (c Nat) (d Nat) (e Nat)) (= (op (op a b Z Z) c d e) (op a (op b c Z Z) d e)))))
; proof goal end

(check-sat)
