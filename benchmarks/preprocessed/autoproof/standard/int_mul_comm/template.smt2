(set-logic UFDT)

; datatypes
(declare-datatypes ((Sign 0)) (((Pos) (Neg))))
(declare-datatypes ((Nat 0)) (((Zero) (Succ (pred Nat)))))
(declare-datatypes ((Z 0)) (((P (P_0 Nat)) (N (N_0 Nat)))))
; datatypes end

; functions declarations
(declare-fun toInteger (Sign Nat) Z)
(declare-fun sign (Z) Sign)
(declare-fun plus (Nat Nat) Nat)
(declare-fun opposite (Sign) Sign)
(declare-fun timesSign (Sign Sign) Sign)
(declare-fun mult (Nat Nat) Nat)
(declare-fun absVal (Z) Nat)
(declare-fun times (Z Z) Z)
(assert
  (forall ((x Sign) (y Nat))
    (= (toInteger x y)
      (ite (is-Neg x) (ite (is-Succ y) (N (pred y)) (P Zero)) (P y)))))
(assert (forall ((x Z)) (= (sign x) (ite (is-N x) Neg Pos))))
(assert
  (forall ((x Nat) (y Nat))
    (= (plus x y) (ite (is-Succ x) (Succ (plus (pred x) y)) y))))
(assert
  (forall ((x Sign)) (= (opposite x) (ite (is-Neg x) Pos Neg))))
(assert
  (forall ((x Sign) (y Sign))
    (= (timesSign x y) (ite (is-Neg x) (opposite y) y))))
(assert
  (forall ((x Nat) (y Nat))
    (= (mult x y) (ite (is-Succ x) (plus y (mult (pred x) y)) Zero))))
(assert
  (forall ((x Z))
    (= (absVal x) (ite (is-N x) (Succ (N_0 x)) (P_0 x)))))
(assert
  (forall ((x Z) (y Z))
    (= (times x y)
      (toInteger (timesSign (sign x) (sign y))
        (mult (absVal x) (absVal y))))))
; functions declarations end

; proof goal
(assert (not (forall ((x Z) (y Z)) (= (times x y) (times y x)))))
; proof goal end

(check-sat)
