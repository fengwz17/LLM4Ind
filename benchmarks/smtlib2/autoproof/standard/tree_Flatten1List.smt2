(set-logic UFDT)
(declare-sort sk_a 0)
(declare-sort fun1 0)
(declare-datatypes ((list2 0))
  (((nil2) (cons2 (head2 sk_a) (tail2 list2)))))
(declare-datatypes ((Tree 0))
  (((Node (Node_0 Tree) (Node_1 sk_a) (Node_2 Tree)) (Nil))))
(declare-datatypes ((list 0))
  (((nil) (cons (head Tree) (tail list)))))
(declare-const lam fun1)
(declare-fun apply1 (fun1 Tree) list2)
(declare-fun flatten1 (list) list2)
(declare-fun append (list2 list2) list2)
(declare-fun concatMap (fun1 list) list2)
(declare-fun flatten0 (Tree) list2)
(assert
  (not (forall ((ps list)) (= (flatten1 ps) (concatMap lam ps)))))
(assert
  (forall ((x list))
    (= (flatten1 x)
      (ite
        (is-cons x)
        (ite
          (is-Nil (head x)) (flatten1 (tail x))
          (ite
            (is-Nil (Node_0 (head x)))
            (cons2 (Node_1 (head x))
              (flatten1 (cons (Node_2 (head x)) (tail x))))
            (flatten1
              (cons
                (Node (Node_0 (Node_0 (head x)))
                  (Node_1 (Node_0 (head x))) (Node_2 (Node_0 (head x))))
                (cons (Node Nil (Node_1 (head x)) (Node_2 (head x))) (tail x))))))
        nil2))))
(assert
  (forall ((x list2) (y list2))
    (= (append x y)
      (ite (is-cons2 x) (cons2 (head2 x) (append (tail2 x) y)) y))))
(assert
  (forall ((x fun1) (y list))
    (= (concatMap x y)
      (ite
        (is-cons y) (append (apply1 x (head y)) (concatMap x (tail y)))
        nil2))))
(assert
  (forall ((x Tree))
    (= (flatten0 x)
      (ite
        (is-Nil x) nil2
        (append (append (flatten0 (Node_0 x)) (cons2 (Node_1 x) nil2))
          (flatten0 (Node_2 x)))))))
(assert (forall ((x Tree)) (= (apply1 lam x) (flatten0 x))))
(check-sat)
