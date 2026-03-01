(set-logic UFDT)

; datatypes
(declare-datatypes ((Bin 0))
  (((One) (ZeroAnd (ZeroAnd_0 Bin)) (OneAnd (OneAnd_0 Bin)))))
; datatypes end

; functions declarations
(declare-fun s (Bin) Bin)
(declare-fun plus (Bin Bin) Bin)
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
; functions declarations end

; proof goal
(assert (not (forall ((x Bin) (y Bin)) (= (plus x y) (plus y x)))))
; proof goal end

(check-sat)
