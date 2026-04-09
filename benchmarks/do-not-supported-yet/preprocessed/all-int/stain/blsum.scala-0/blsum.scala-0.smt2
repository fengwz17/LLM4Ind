(set-logic UFNIA)


(declare-fun isPow2 (Int) Bool)
(assert (forall ((x Int)) (=> (<= x 0) (= (isPow2 x) false))))
(assert (forall ((x Int)) (=> (= x 1) (= (isPow2 x) true))))
(assert (forall ((x Int)) (=> (and (> x 1) (= (mod x 2) 1)) (= (isPow2 x) false))))
(assert (forall ((x Int)) (=> (and (> x 1) (= (mod x 2) 0)) (= (isPow2 x) (isPow2 (div x 2))))))

(declare-fun bitLength (Int) Int)
(assert (forall ((x Int)) (=> (<= x 0) (= (bitLength x) 0))))
(assert (forall ((x Int)) (=> (> x 0) (= (bitLength x) (+ (bitLength (div x 2)) 1)))))

(assert (not (forall ((x Int) (y Int)) (=> (and (>= x 1) (>= y 1) (isPow2 x) (isPow2 y)) (= (- (+ (bitLength x) (bitLength y)) 2) (- (bitLength (* x y)) 1))))))

(check-sat)
