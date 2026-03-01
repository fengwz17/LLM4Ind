(set-logic UFDT)

; datatypes
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
; datatypes end

; functions declarations
(declare-fun add3acc (Nat Nat Nat) Nat)
(declare-fun mul3acc (Nat Nat Nat) Nat)
(assert
  (forall ((x Nat) (y Nat) (z Nat))
    (= (add3acc x y z)
      (ite
        (is-S x) (add3acc (p x) (S y) z)
        (ite (is-S y) (add3acc Z (p y) (S z)) z)))))
(assert
  (forall ((x Nat) (y Nat) (z Nat))
    (= (mul3acc x y z)
      (ite
        (is-S x)
        (ite
          (is-S y)
          (ite
            (is-S z)
            (ite
              (is-S (p x))
              (S
                (add3acc (mul3acc (S (p (p x))) (p y) (p z))
                  (add3acc (mul3acc (S Z) (p y) (p z))
                    (mul3acc (S (p (p x))) (S Z) (p z))
                    (mul3acc (S (p (p x))) (p y) (S Z)))
                  (add3acc (S (p (p x))) (p y) (p z))))
              (ite
                (is-S (p y))
                (S
                  (add3acc (mul3acc Z (S (p (p y))) (p z))
                    (add3acc (mul3acc (S Z) (S (p (p y))) (p z))
                      (mul3acc Z (S Z) (p z)) (mul3acc Z (S (p (p y))) (S Z)))
                    (add3acc Z (S (p (p y))) (p z))))
                (ite
                  (is-S (p z))
                  (S
                    (add3acc (mul3acc Z Z (S (p (p z))))
                      (add3acc (mul3acc (S Z) Z (S (p (p z))))
                        (mul3acc Z (S Z) (S (p (p z)))) (mul3acc Z Z (S Z)))
                      (add3acc Z Z (S (p (p z))))))
                  (S Z))))
            Z)
          Z)
        Z))))
; functions declarations end

; proof goal
(assert (not (forall ((x Nat) (y Nat) (z Nat)) (= (mul3acc x y z) (mul3acc z y x)))))
; proof goal end

(check-sat)
