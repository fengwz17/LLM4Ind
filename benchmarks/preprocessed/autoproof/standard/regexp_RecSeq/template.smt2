(set-logic UFDT)

; datatypes
(declare-datatypes ((A 0)) (((X) (Y))))
(declare-datatypes ((R 0))
  (( (Nil)
     (Eps) (Atom (Atom_0 A)) (Plus (Plus_0 R) (Plus_1 R))
     (Seq (Seq_0 R) (Seq_1 R)) (Star (Star_0 R)))))
(declare-datatypes ((list2 0))
  (((nil2) (cons2 (head2 A) (tail2 list2)))))
(declare-datatypes ((Pair 0))
  (((Pair2 (first list2) (second list2)))))
(declare-datatypes ((list 0))
  (((nil) (cons (head Pair) (tail list)))))
; datatypes end

; functions declarations
(declare-fun seq (R R) R)
(declare-fun plus (R R) R)
(declare-fun eqA (A A) Bool)
(declare-fun eps (R) Bool)
(declare-fun epsR (R) R)
(declare-fun step (R A) R)
(declare-fun recognise (R list2) Bool)
(declare-fun recognisePair (R R list) Bool)
(declare-fun consfst (A list) list)
(declare-fun split (list2) list)
(assert
  (forall ((x R) (y R))
    (= (seq x y)
      (ite
        (is-Nil x) Nil
        (ite
          (is-Nil y) Nil (ite (is-Eps x) y (ite (is-Eps y) x (Seq x y))))))))
(assert
  (forall ((x R) (y R))
    (= (plus x y) (ite (is-Nil x) y (ite (is-Nil y) x (Plus x y))))))
(assert
  (forall ((x A) (y A))
    (= (eqA x y) (ite (is-Y x) (is-Y y) (not (is-Y y))))))
(assert
  (forall ((x R))
    (= (eps x)
      (ite
        (is-Star x) true
        (ite
          (is-Seq x) (and (eps (Seq_0 x)) (eps (Seq_1 x)))
          (ite
            (is-Plus x) (or (eps (Plus_0 x)) (eps (Plus_1 x))) (is-Eps x)))))))
(assert (forall ((x R)) (= (epsR x) (ite (eps x) Eps Nil))))
(assert
  (forall ((x R) (y A))
    (= (step x y)
      (ite
        (is-Star x) (seq (step (Star_0 x) y) (Star (Star_0 x)))
        (ite
          (is-Seq x)
          (plus (seq (step (Seq_0 x) y) (Seq_1 x))
            (seq (epsR (Seq_0 x)) (step (Seq_1 x) y)))
          (ite
            (is-Plus x) (plus (step (Plus_0 x) y) (step (Plus_1 x) y))
            (ite (is-Atom x) (ite (eqA (Atom_0 x) y) Eps Nil) Nil)))))))
(assert
  (forall ((x R) (y list2))
    (= (recognise x y)
      (ite
        (is-cons2 y) (recognise (step x (head2 y)) (tail2 y)) (eps x)))))
(assert
  (forall ((x R) (y R) (z list))
    (= (recognisePair x y z)
      (ite
        (is-cons z)
        (or
          (and (recognise x (first (head z)))
            (recognise y (second (head z))))
          (recognisePair x y (tail z)))
        false))))
(assert
  (forall ((x A) (y list))
    (= (consfst x y)
      (ite
        (is-cons y)
        (cons (Pair2 (cons2 x (first (head y))) (second (head y)))
          (consfst x (tail y)))
        nil))))
(assert
  (forall ((x list2))
    (= (split x)
      (ite
        (is-cons2 x)
        (cons (Pair2 nil2 (cons2 (head2 x) (tail2 x)))
          (consfst (head2 x) (split (tail2 x))))
        (cons (Pair2 nil2 nil2) nil)))))
; functions declarations end

; proof goal
(assert (not (forall ((p R) (q R) (s list2)) (= (recognise (Seq p q) s) (recognisePair p q (split s))))))
; proof goal end

(check-sat)
