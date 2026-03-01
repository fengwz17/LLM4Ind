(set-logic UFDTLIA)

; datatypes
(declare-datatypes ((list 0)) (((nil) (cons (head Int) (tail list)))))
(declare-datatypes ((Tree 0))
  (( (TNode (TNode_0 Tree) (TNode_1 Int) (TNode_2 Tree))
     (TNil))))
; datatypes end

; functions declarations
(declare-fun insert2 (Int list) list)
(declare-fun isort (list) list)
(declare-fun flatten (Tree list) list)
(declare-fun add (Int Tree) Tree)
(declare-fun toTree (list) Tree)
(declare-fun tsort (list) list)
(assert
  (forall ((x Int) (y list))
    (= (insert2 x y)
      (ite
        (is-cons y)
        (ite
          (<= x (head y)) (cons x (cons (head y) (tail y)))
          (cons (head y) (insert2 x (tail y))))
        (cons x nil)))))
(assert
  (forall ((x list))
    (= (isort x)
      (ite (is-cons x) (insert2 (head x) (isort (tail x))) nil))))
(assert
  (forall ((x Tree) (y list))
    (= (flatten x y)
      (ite
        (is-TNil x) y
        (flatten (TNode_0 x)
          (cons (TNode_1 x) (flatten (TNode_2 x) y)))))))
(assert
  (forall ((x Int) (y Tree))
    (= (add x y)
      (ite
        (is-TNil y) (TNode TNil x TNil)
        (ite
          (<= x (TNode_1 y))
          (TNode (add x (TNode_0 y)) (TNode_1 y) (TNode_2 y))
          (TNode (TNode_0 y) (TNode_1 y) (add x (TNode_2 y))))))))
(assert
  (forall ((x list))
    (= (toTree x)
      (ite (is-cons x) (add (head x) (toTree (tail x))) TNil))))
(assert (forall ((x list)) (= (tsort x) (flatten (toTree x) nil))))
(check-sat)
; functions declarations end

; proof goal
(assert (not (forall ((x list)) (= (tsort x) (isort x)))))
; proof goal end

