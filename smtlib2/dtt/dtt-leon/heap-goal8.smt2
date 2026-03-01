(set-logic UFDTLIA)

(declare-fun less (Int Int) Bool)
;(assert (not (less 0 0)))
;(assert (forall ((x Int)) (=> (>= x 0) (less 0 (+ 1 x)))))
;(assert (forall ((x Int) (y Int)) (=> (and (>= x 0) (>= y 0)) (= (less (+ 1 x) (+ 1 y)) (less x y)))))
; less equivalent
(assert (forall ((x Int) (y Int)) (=> (and (>= x 0) (>= y 0)) (= (less x y) (< x y)))))

(define-fun leq ((x Int) (y Int)) Bool (<= x y))

(declare-fun plus (Int Int) Int)
;(assert (forall ((n Int)) (=> (>= n 0) (= (plus 0 n) n))))
;(assert (forall ((n Int) (m Int)) (=> (and (>= n 0) (>= m 0)) (= (plus (+ 1 n) m) (+ 1 (plus n m))))))
; plus equivalent
(assert (forall ((n Int) (m Int)) (=> (and (>= n 0) (>= m 0)) (= (plus n m) (+ n m)))))

; lists      
(declare-datatypes ((Lst 0)) (((cons (head Int) (tail Lst)) (nil))))

(declare-fun len (Lst) Int)
(assert (= (len nil) 0))
(assert (forall ((x Int) (y Lst)) (= (len (cons x y)) (+ 1 (len y)))))
; since len returns Nat, we can assume this "lemma"
;;; (assert (forall ((x Lst)) (>= (len x) 0)))

(declare-fun rsorted (Lst) Bool)
(assert (rsorted nil))
(assert (forall ((x Int)) (rsorted (cons x nil))))
(assert (forall ((x Int) (z Int) (y Lst)) (= (rsorted (cons x (cons z y))) (and (rsorted (cons z y)) (leq z x)))))

(declare-fun sorted (Lst) Bool)
(assert (sorted nil))
(assert (forall ((x Int)) (sorted (cons x nil))))
(assert (forall ((x Int) (z Int) (y Lst)) (= (sorted (cons x (cons z y))) (and (rsorted (cons z y)) (leq x z)))))

; heaps
(declare-datatypes ((Heap 0)) (((hleaf) (heap (rk Int) (value Int) (hleft Heap) (hright Heap)))))

(declare-fun rightHeight (Heap) Int)
(assert (= (rightHeight hleaf) 0))
(assert (forall ((k Int) (v Int) (l Heap) (r Heap)) (= (rightHeight (heap k v l r)) (+ 1 (rightHeight r)))))
; since returns Nat, we can assume this "lemma"
;;; (assert (forall ((x Heap)) (>= (rightHeight x) 0)))

(declare-fun rank (Heap) Int)
(assert (= (rank hleaf) 0))
(assert (forall ((k Int) (v Int) (l Heap) (r Heap)) (= (rank (heap k v l r)) k)))

(declare-fun hasLeftistProperty (Heap) Bool)
(assert (hasLeftistProperty hleaf))
(assert (forall ((k Int) (v Int) (l Heap) (r Heap)) (= (hasLeftistProperty (heap k v l r)) (and (hasLeftistProperty l) (hasLeftistProperty r) 
                                                                                                (leq (rightHeight r) (rightHeight l)) 
                                                                                                (= k (+ 1 (rightHeight r)))))))
                                                                                                
(declare-fun hsize (Heap) Int)
(assert (= (hsize hleaf) 0))
(assert (forall ((k Int) (v Int) (l Heap) (r Heap)) (= (hsize (heap k v l r)) (+ 1 (plus (hsize l) (hsize r))))))
; since returns Nat, we can assume this "lemma"
;;; (assert (forall ((x Heap)) (>= (hsize x) 0)))

(declare-fun mergea (Int Heap Heap) Heap)
(assert (forall ((v Int) (l Heap) (r Heap)) (= (mergea v l r) (ite (leq (rank r) (rank l)) (heap (+ 1 (rank r)) v l r) (heap (+ 1 (rank l)) v r l)))))

(declare-fun merge (Heap Heap) Heap)
(assert (forall ((h Heap)) (= (merge h hleaf) h)))
(assert (forall ((h Heap)) (= (merge hleaf h) h)))
(assert (forall ((k1 Int) (v1 Int) (l1 Heap) (r1 Heap) (k2 Int) (v2 Int) (l2 Heap) (r2 Heap)) (= (merge (heap k1 v1 l1 r1) (heap k2 v2 l2 r2)) 
                                                                                                 (ite (less v2 v1) 
                                                                                                      (mergea v1 l1 (merge r1 (heap k2 v2 l2 r2)))
                                                                                                      (mergea v2 l2 (merge (heap k1 v1 l1 r1) r2))))))
                                                                                                      
(declare-fun hinsert (Heap Int) Heap)                                                                                                      
(assert (forall ((h Heap) (n Int)) (= (hinsert h n) (merge (heap 1 n hleaf hleaf) h))))

(declare-fun hinsert-all (Lst Heap) Heap)
(assert (forall ((h Heap)) (= (hinsert-all nil h) h)))
(assert (forall ((h Heap) (n Int) (l Lst)) (= (hinsert-all (cons n l) h) (hinsert (hinsert-all l h) n))))

(declare-fun qheapsorta (Heap Lst) Lst)
(assert (forall ((l Lst)) (= (qheapsorta hleaf l) l)))
(assert (forall ((k Int) (v Int) (l Heap) (r Heap) (x Lst)) (= (qheapsorta (heap k v l r) x) (qheapsorta (merge l r) (cons v x)))))

(declare-fun qheapsort (Lst) Lst)
(assert (forall ((l Lst)) (= (qheapsort l) (qheapsorta (hinsert-all l hleaf) nil))))

(declare-fun heapsorta (Heap) Lst)
(assert (= (heapsorta hleaf) nil))
(assert (forall ((k Int) (v Int) (l Heap) (r Heap)) (= (heapsorta (heap k v l r)) (cons v (heapsorta (merge l r))))))

(declare-fun heapsort (Lst) Lst)
(assert (forall ((l Lst)) (= (heapsort l) (heapsorta (hinsert-all l hleaf)))))

; proven

; conjecture
(assert (not
 
(forall ((x Heap) (n Int)) (=> (hasLeftistProperty x) (= (hsize (hinsert x n)) (+ 1 (hsize x))))) ; G-heap-8  

))
(check-sat)
