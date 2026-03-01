(set-logic UFDT)

; datatypes
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-datatypes ((Bin 0))
  (((One) (ZeroAnd (ZeroAnd_0 Bin)) (OneAnd (OneAnd_0 Bin)))))
; datatypes end

; functions declarations
(declare-fun s (Bin) Bin)
(declare-fun plus (Nat Nat) Nat)
(declare-fun toNat (Bin) Nat)
(assert
  (forall ((x Bin))
    (= (s x)
      (ite
        (is-OneAnd x) (ZeroAnd (s (OneAnd_0 x)))
        (ite (is-ZeroAnd x) (OneAnd (ZeroAnd_0 x)) (ZeroAnd One))))))
(assert
  (forall ((x Nat) (y Nat))
    (= (plus x y) (ite (is-S x) (S (plus (p x) y)) y))))
(assert
  (forall ((x Bin))
    (= (toNat x)
      (ite
        (is-OneAnd x) (S (plus (toNat (OneAnd_0 x)) (toNat (OneAnd_0 x))))
        (ite
          (is-ZeroAnd x) (plus (toNat (ZeroAnd_0 x)) (toNat (ZeroAnd_0 x)))
          (S Z))))))
; functions declarations end

; proof goal
(assert (not (forall ((n Bin)) (= (toNat (s n)) (S (toNat n))))))
; proof goal end

(check-sat)
