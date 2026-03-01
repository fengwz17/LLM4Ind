(set-logic UFDT)
(declare-sort sk_a 0)
(declare-datatypes ((list 0))
  (((nil) (cons (head sk_a) (tail list)))))
(declare-datatypes ((Tree 0))
  (((Node (Node_0 Tree) (Node_1 sk_a) (Node_2 Tree)) (Nil))))
(declare-fun flatten3 (Tree) list)
(declare-fun append (list list) list)
(declare-fun flatten0 (Tree) list)
(assert (not (forall ((p Tree)) (= (flatten3 p) (flatten0 p)))))
(assert
  (forall ((x Tree))
    (= (flatten3 x)
      (ite
        (is-Nil x) nil
        (ite
          (is-Nil (Node_0 x)) (cons (Node_1 x) (flatten3 (Node_2 x)))
          (flatten3
            (Node (Node_0 (Node_0 x))
              (Node_1 (Node_0 x))
              (Node (Node_2 (Node_0 x)) (Node_1 x) (Node_2 x)))))))))
(assert
  (forall ((x list) (y list))
    (= (append x y)
      (ite (is-cons x) (cons (head x) (append (tail x) y)) y))))
(assert
  (forall ((x Tree))
    (= (flatten0 x)
      (ite
        (is-Nil x) nil
        (append (append (flatten0 (Node_0 x)) (cons (Node_1 x) nil))
          (flatten0 (Node_2 x)))))))
(check-sat)
