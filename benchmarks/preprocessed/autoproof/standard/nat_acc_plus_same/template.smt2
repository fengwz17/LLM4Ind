(set-logic UFDT)

; datatypes
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
; datatypes end

; functions declarations
(declare-fun plus (Nat Nat) Nat)
(declare-fun acc_plus (Nat Nat) Nat)
(assert
  (forall ((x Nat) (y Nat))
    (= (plus x y) (ite (is-S x) (S (plus (p x) y)) y))))
(assert
  (forall ((x Nat) (y Nat))
    (= (acc_plus x y) (ite (is-S x) (acc_plus (p x) (S y)) y))))
; functions declarations end

; proof goal
(assert (not (forall ((x Nat) (y Nat)) (= (plus x y) (acc_plus x y)))))
; proof goal end

(check-sat)
