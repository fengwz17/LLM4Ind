(set-logic ALL)

(declare-fun Pow (Int Int) Int)
(assert (forall ((base Int) (exp Int)) (=> (<= exp 0) (= (Pow base exp) 1))))
(assert (forall ((base Int) (exp Int)) (=> (> exp 0) (= (Pow base exp) (* base (Pow base (- exp 1)))))))

(declare-fun a (Int Int Int) Int)
(assert (forall ((n Int) (alpha Int) (beta Int)) (=> (<= n 0) (= (a n alpha beta) (+ (+ alpha beta) 16)))))
(assert (forall ((n Int) (alpha Int) (beta Int)) (=> (= n 1) (= (a n alpha beta) (+ (- (* (- 2) alpha) (* 3 beta)) 64)))))
(assert (forall ((n Int) (alpha Int) (beta Int)) (=> (> n 1) (= (a n alpha beta) (+ (- (* (- 5) (a (- n 1) alpha beta)) (* 6 (a (- n 2) alpha beta))) (* 42 (Pow 4 n))) ))))


(assert (not (forall ((n Int) (alpha Int) (beta Int)) (=> (>= n 0) (= (a n alpha beta) (+ (+ (* alpha (Pow (- 2) n)) (* beta (Pow (- 3) n))) (Pow 4 (+ n 2)) ))))))
(check-sat)