(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun f (Int Int Int Int Int Int) Int)
(assert (forall ((a Int) (b Int) (c Int) (d Int) (k Int) (init Int)) (=> (<= k 0) (= (f a b c d k init) init))))
(assert (forall ((a Int) (b Int) (c Int) (d Int) (k Int) (init Int)) (=> (> k 0) (= (f a b c d k init) (+ (* a (f a b c d (- k 1) init)) (* c (Pow b (* k d))))))))

(assert (not (forall ((a Int) (b Int) (c Int) (d Int) (k Int) (init Int)) (=> (and (>= a 1) (> b 1) (>= c 0) (> d 0) (> k 0) (> init 0) (= a (Pow b d))) (= (f a b c d k init) (+ (* init (Pow b (* k d))) (* c (Pow b (* k d)) k)) )))))
(check-sat)