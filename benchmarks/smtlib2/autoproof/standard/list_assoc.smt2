(set-logic UFDT)
(declare-sort sk_a 0)
(declare-sort sk_b 0)
(declare-sort sk_c 0)
(declare-sort fun1 0)
(declare-sort fun12 0)
(declare-sort fun13 0)
(declare-datatypes ((list3 0))
  (((nil3) (cons3 (head3 sk_c) (tail3 list3)))))
(declare-datatypes ((list2 0))
  (((nil2) (cons2 (head2 sk_b) (tail2 list2)))))
(declare-datatypes ((list 0))
  (((nil) (cons (head sk_a) (tail list)))))

(declare-fun lam (fun1 fun13) fun12)
(declare-fun apply1 (fun1 sk_a) list2)
(declare-fun apply12 (fun12 sk_a) list3)
(declare-fun apply13 (fun13 sk_b) list3)
(declare-fun append (list2 list2) list2)
(declare-fun append2 (list3 list3) list3)
(declare-fun bind (list fun1) list2)
(declare-fun bind2 (list fun12) list3)
(declare-fun bind3 (list2 fun13) list3)
(assert
  (not
    (forall ((m list) (f fun1) (g fun13))
      (= (bind3 (bind m f) g) (bind2 m (lam f g))))))
(assert
  (forall ((x list2) (y list2))
    (= (append x y)
      (ite (is-cons2 x) (cons2 (head2 x) (append (tail2 x) y)) y))))
(assert
  (forall ((x list3) (y list3))
    (= (append2 x y)
      (ite (is-cons3 x) (cons3 (head3 x) (append2 (tail3 x) y)) y))))
(assert
  (forall ((x list) (y fun1))
    (= (bind x y)
      (ite
        (is-cons x) (append (apply1 y (head x)) (bind (tail x) y)) nil2))))
(assert
  (forall ((x list) (y fun12))
    (= (bind2 x y)
      (ite
        (is-cons x) (append2 (apply12 y (head x)) (bind2 (tail x) y))
        nil3))))
(assert
  (forall ((x list2) (y fun13))
    (= (bind3 x y)
      (ite
        (is-cons2 x) (append2 (apply13 y (head2 x)) (bind3 (tail2 x) y))
        nil3))))
(assert
  (forall ((f fun1) (g fun13) (x sk_a))
    (= (apply12 (lam f g) x) (bind3 (apply1 f x) g))))
(check-sat)
