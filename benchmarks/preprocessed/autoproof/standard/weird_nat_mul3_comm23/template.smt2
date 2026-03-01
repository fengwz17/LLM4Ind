(set-logic UFDT)

; datatypes
(declare-datatypes ((Nat 0)) (((Z) (S (p Nat)))))
; datatypes end

; functions declarations
(declare-fun add3 (Nat Nat Nat) Nat)
(declare-fun mul3 (Nat Nat Nat) Nat)
(assert
  (forall ((x Nat) (y Nat) (z Nat))
    (= (add3 x y z)
      (ite
        (is-S x) (S (add3 (p x) y z))
        (ite (is-S y) (S (add3 Z (p y) z)) z)))))
(assert
  (forall ((x Nat) (y Nat) (z Nat))
    (= (mul3 x y z)
      (ite
        (is-S x)
        (ite
          (is-S y)
          (ite
            (is-S z)
            (ite
              (is-S (p x))
              (S
                (add3 (mul3 (S (p (p x))) (p y) (p z))
                  (add3 (mul3 (S Z) (p y) (p z))
                    (mul3 (S (p (p x))) (S Z) (p z)) (mul3 (S (p (p x))) (p y) (S Z)))
                  (add3 (S (p (p x))) (p y) (p z))))
              (ite
                (is-S (p y))
                (S
                  (add3 (mul3 Z (S (p (p y))) (p z))
                    (add3 (mul3 (S Z) (S (p (p y))) (p z))
                      (mul3 Z (S Z) (p z)) (mul3 Z (S (p (p y))) (S Z)))
                    (add3 Z (S (p (p y))) (p z))))
                (ite
                  (is-S (p z))
                  (S
                    (add3 (mul3 Z Z (S (p (p z))))
                      (add3 (mul3 (S Z) Z (S (p (p z))))
                        (mul3 Z (S Z) (S (p (p z)))) (mul3 Z Z (S Z)))
                      (add3 Z Z (S (p (p z))))))
                  (S Z))))
            Z)
          Z)
        Z))))
; functions declarations end

; proof goal
(assert (not (forall ((x Nat) (y Nat) (z Nat)) (= (mul3 x y z) (mul3 x z y)))))
; proof goal end

(check-sat)
