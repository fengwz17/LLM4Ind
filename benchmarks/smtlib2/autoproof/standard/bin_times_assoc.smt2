(set-logic UFDT)
(declare-datatypes ((Bin 0))
  (((One) (ZeroAnd (ZeroAnd_0 Bin)) (OneAnd (OneAnd_0 Bin)))))
(declare-fun s (Bin) Bin)
(declare-fun plus (Bin Bin) Bin)
(declare-fun times (Bin Bin) Bin)
(assert
  (not
    (forall ((x Bin) (y Bin) (z Bin))
      (= (times x (times y z)) (times (times x y) z)))))
(assert
  (forall ((x Bin))
    (= (s x)
      (ite
        (is-OneAnd x) (ZeroAnd (s (OneAnd_0 x)))
        (ite (is-ZeroAnd x) (OneAnd (ZeroAnd_0 x)) (ZeroAnd One))))))
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
(check-sat)
