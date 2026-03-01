(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (* 8 (f (- n 1))) (* (Pow 2 n) (Pow 2 n)))) ) ))

(assert (not (forall ((k Int)) (=> (>= k 0) (= (f k) (+ (* (- (Pow 2 k)) (Pow 2 k)) (* (Pow 2 k) (Pow 2 k) (Pow 2 k))))))))
(check-sat)