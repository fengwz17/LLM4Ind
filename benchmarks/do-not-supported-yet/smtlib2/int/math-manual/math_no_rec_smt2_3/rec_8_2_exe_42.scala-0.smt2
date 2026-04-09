(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun f (Int) Int)
(assert (forall ((n Int)) (=> (<= n 0) (= (f n) 0))))
(assert (forall ((n Int)) (=> (= n 1) (= (f n) 1))))
(assert (forall ((n Int)) (=> (> n 1) (= (f n) (+ (f (- n 1)) (f (- n 2)) )) ) ))

(declare-fun a (Int Int Int) Int)
(assert (forall ((n Int) (s Int) (t Int)) (=> (<= n 0) (= (a n s t) s))))
(assert (forall ((n Int) (s Int) (t Int)) (=> (= n 1) (= (a n s t) t))))
(assert (forall ((n Int) (s Int) (t Int)) (=> (> n 1) (= (a n s t) (+ (a (- n 1) s t) (a (- n 2) s t))))))

(assert (not (forall ((n Int) (s Int) (t Int)) (=> (>= n 1) (= (a n s t) (+ (* s (f (- n 1))) (* t (f n)) ) )))))
(check-sat)