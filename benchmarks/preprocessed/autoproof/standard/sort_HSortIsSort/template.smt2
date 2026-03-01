(set-logic UFDTLIA)

; datatypes
(declare-datatypes ((list2 0))
  (((nil2) (cons2 (head2 Int) (tail2 list2)))))
(declare-datatypes ((Heap 0))
  (((Node (Node_0 Heap) (Node_1 Int) (Node_2 Heap)) (Nil))))
(declare-datatypes ((list 0))
  (((nil) (cons (head Heap) (tail list)))))
; datatypes end

; functions declarations
(declare-fun toHeap2 (list2) list)
(declare-fun insert2 (Int list2) list2)
(declare-fun isort (list2) list2)
(declare-fun hmerge (Heap Heap) Heap)
(declare-fun hpairwise (list) list)
(declare-fun hmerging (list) Heap)
(declare-fun toHeap (list2) Heap)
(declare-fun toList (Heap) list2)
(declare-fun hsort (list2) list2)
(assert
  (forall ((x list2))
    (= (toHeap2 x)
      (ite
        (is-cons2 x) (cons (Node Nil (head2 x) Nil) (toHeap2 (tail2 x)))
        nil))))
(assert
  (forall ((x Int) (y list2))
    (= (insert2 x y)
      (ite
        (is-cons2 y)
        (ite
          (<= x (head2 y)) (cons2 x (cons2 (head2 y) (tail2 y)))
          (cons2 (head2 y) (insert2 x (tail2 y))))
        (cons2 x nil2)))))
(assert
  (forall ((x list2))
    (= (isort x)
      (ite (is-cons2 x) (insert2 (head2 x) (isort (tail2 x))) nil2))))
(assert
  (forall ((x Heap) (y Heap))
    (= (hmerge x y)
      (ite
        (is-Nil x) y
        (ite
          (is-Nil y) (Node (Node_0 x) (Node_1 x) (Node_2 x))
          (ite
            (<= (Node_1 x) (Node_1 y))
            (Node (hmerge (Node_2 x) (Node (Node_0 y) (Node_1 y) (Node_2 y)))
              (Node_1 x) (Node_0 x))
            (Node (hmerge (Node (Node_0 x) (Node_1 x) (Node_2 x)) (Node_2 y))
              (Node_1 y) (Node_0 y))))))))
(assert
  (forall ((x list))
    (= (hpairwise x)
      (ite
        (is-cons x)
        (ite
          (is-cons (tail x))
          (cons (hmerge (head x) (head (tail x)))
            (hpairwise (tail (tail x))))
          (cons (head x) nil))
        nil))))
(assert
  (forall ((x list))
    (= (hmerging x)
      (ite
        (is-cons x)
        (ite
          (is-cons (tail x))
          (hmerging
            (hpairwise (cons (head x) (cons (head (tail x)) (tail (tail x))))))
          (head x))
        Nil))))
(assert (forall ((x list2)) (= (toHeap x) (hmerging (toHeap2 x)))))
(assert
  (forall ((x Heap))
    (= (toList x)
      (ite
        (is-Nil x) nil2
        (cons2 (Node_1 x) (toList (hmerge (Node_0 x) (Node_2 x))))))))
(assert (forall ((x list2)) (= (hsort x) (toList (toHeap x)))))
(check-sat)
; functions declarations end

; proof goal
(assert (not (forall ((x list2)) (= (hsort x) (isort x)))))
; proof goal end

