(set-logic UFDT)
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
(declare-datatypes ((Bin 0))
  (((One) (ZeroAnd (ZeroAnd_0 Bin)) (OneAnd (OneAnd_0 Bin)))))
(declare-fun s (Bin) Bin)
(declare-fun plus2 (Nat Nat) Nat)
(declare-fun toNat (Bin) Nat)
(declare-fun plus (Bin Bin) Bin)
(declare-fun times (Bin Bin) Bin)
(declare-fun mult (Nat Nat) Nat)
(assert
  (not
    (forall ((x Bin) (y Bin))
      (= (toNat (times x y)) (mult (toNat x) (toNat y))))))
(assert
  (forall ((x Bin))
    (= (s x)
      (ite
        (is-OneAnd x) (ZeroAnd (s (OneAnd_0 x)))
        (ite (is-ZeroAnd x) (OneAnd (ZeroAnd_0 x)) (ZeroAnd One))))))
(assert
  (forall ((x Nat) (y Nat))
    (= (plus2 x y) (ite (is-S x) (S (plus2 (p x) y)) y))))
(assert
  (forall ((x Bin))
    (= (toNat x)
      (ite
        (is-OneAnd x) (S (plus2 (toNat (OneAnd_0 x)) (toNat (OneAnd_0 x))))
        (ite
          (is-ZeroAnd x) (plus2 (toNat (ZeroAnd_0 x)) (toNat (ZeroAnd_0 x)))
          (S Z))))))
(assert
  (forall ((x Bin) (y Bin))
    (= (plus x y)
      (ite
        (is-OneAnd x)
        (ite
          (is-OneAnd y) (ZeroAnd (s (plus (OneAnd_0 x) (OneAnd_0 y))))
          (ite
            (is-ZeroAnd y) (OneAnd (plus (OneAnd_0 x) (ZeroAnd_0 y)))
            (s (OneAnd (OneAnd_0 x)))))
        (ite
          (is-ZeroAnd x)
          (ite
            (is-OneAnd y) (OneAnd (plus (ZeroAnd_0 x) (OneAnd_0 y)))
            (ite
              (is-ZeroAnd y) (ZeroAnd (plus (ZeroAnd_0 x) (ZeroAnd_0 y)))
              (s (ZeroAnd (ZeroAnd_0 x)))))
          (s y))))))
(assert
  (forall ((x Bin) (y Bin))
    (= (times x y)
      (ite
        (is-OneAnd x) (plus (ZeroAnd (times (OneAnd_0 x) y)) y)
        (ite (is-ZeroAnd x) (ZeroAnd (times (ZeroAnd_0 x) y)) y)))))
(assert
  (forall ((x Nat) (y Nat))
    (= (mult x y) (ite (is-S x) (plus2 y (mult (p x) y)) Z))))
(check-sat)
