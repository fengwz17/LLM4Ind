(set-logic UFDT)
(declare-datatypes ((A 0)) (((X) (Y))))
(declare-datatypes ((R 0))
  (((Nil)
     (Eps) (Atom (Atom_0 A)) (Plus (Plus_0 R) (Plus_1 R))
     (Seq (Seq_0 R) (Seq_1 R)) (Star (Star_0 R)))))
(declare-datatypes ((list 0)) (((nil) (cons (head A) (tail list)))))
(declare-fun seq (R R) R)
(declare-fun plus (R R) R)
(declare-fun eqA (A A) Bool)
(declare-fun eps (R) Bool)
(declare-fun epsR (R) R)
(declare-fun step (R A) R)
(declare-fun recognise (R list) Bool)
(assert
  (not
    (forall ((p R) (q R) (r R) (s list))
      (= (recognise (Seq p (Seq q r)) s)
        (recognise (Seq (Seq p q) r) s)))))
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
  (forall ((x R) (y list))
    (= (recognise x y)
      (ite (is-cons y) (recognise (step x (head y)) (tail y)) (eps x)))))
(check-sat)
