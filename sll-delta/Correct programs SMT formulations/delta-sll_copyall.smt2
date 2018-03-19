(declare-sort Loc)
;Sets
(define-sort Set (T) (Array T Bool))

(declare-const empInt (Set Int))
(assert (= empInt ((as const (Set Int)) false)))

(declare-const empLoc (Set Loc))
(assert (= empLoc ((as const (Set Loc)) false)))

;; Multisets
(define-sort MultiSet (T) (Array T Int))

(define-fun mult-union ((first (MultiSet Int)) 
  (second (MultiSet Int)) ) (MultiSet Int)
  ((_ map (+ (Int Int) Int)) first second)
  )
(define-fun mult-store ((original (MultiSet Int))
(key Int) (value Int))	(MultiSet Int)
 (store original key (+ (select original key) value))
)
(declare-const mult-empInt (MultiSet Int))
(assert (= mult-empInt ((as const (MultiSet Int)) 0)) )

;;-----------------------------------------------------------
(declare-const n (Array Loc Loc))
(declare-const n2 (Array Loc Loc))
(declare-fun t (Loc) Loc )
(declare-fun key (Loc) Int )
(declare-fun ls (Loc Loc) Bool )
(declare-fun ls2 (Loc Loc) Bool )
(declare-fun hls (Loc Loc) (Set Loc) )
(declare-fun hls2 (Loc Loc) (Set Loc) )
(declare-fun mkeys (Loc Loc) (MultiSet Int) )
(declare-fun mkeys2 (Loc Loc) (MultiSet Int) )
(declare-fun lslen (Loc Loc) Int)
(declare-fun ls2len (Loc Loc) Int)
(declare-fun sorted (Loc Loc) Bool)
(declare-fun sorted2 (Loc Loc) Bool)
(declare-fun revsorted (Loc Loc) Bool)
(declare-fun revsorted2 (Loc Loc) Bool)
(declare-fun minls (Loc Loc) Int)
(declare-fun minls2 (Loc Loc) Int)
(declare-fun maxls (Loc Loc) Int)
(declare-fun maxls2 (Loc Loc) Int)
(declare-fun d (Loc Loc) Int)
(declare-fun d2 (Loc Loc) Int)
(declare-fun hlist_measure (Loc) (Set Loc) )
(declare-fun length_measure (Loc) Int )
(declare-fun max_measure (Loc) Int )
(declare-fun min_measure (Loc) Int )
(declare-fun sorted_measure (Loc) Bool )
(declare-fun revsorted_measure (Loc) Bool )
(define-fun circ_ls ((front Loc) (back Loc)) Bool
(and (ls front back) (= (select n back) front))
)
(define-fun circ_ls2 ((front Loc) (back Loc)) Bool
(and (ls2 front back) (= (select n2 back) front))
)
;;-----------------------------------------------------------
(define-fun hls_separate ((first Loc) (second Loc)) Bool
(=> (not (= first second)) 
   (= (intersect (hlist_measure first ) 
                 (hlist_measure second ) 
	  ) 
   empLoc)
))

;;-----------------------------------------------------------
(define-fun minInt ((first Int) (second Int)) Int
(ite (< first second) first second)
)
(define-fun maxInt ((first Int) (second Int)) Int
(ite (> first second) first second)
)
;;-----------------------------------------------------------


;;-----------------------------------------------------------
(define-fun t_structure_for_sorted_measure ((w Loc)) Bool
(=> (or (= (min_measure w) (max_measure w)) (= (length_measure w ) 1)) 
    (and 
	  (sorted_measure w )
	  (revsorted_measure w )
)))

;;-----------------------------------------------------------
;;nil node
(declare-const nil Loc)
(assert (= (key nil) -1))
;next node for nil defined in base
(assert (= (t nil) nil) )

;;-----------------------------------------------------------
(declare-const inDelta (Set Loc) )
(declare-const inVariables (Set Loc) )

;;------------------------------------------------------------------
;;Closed system assumptions and range restrictions for t
(define-fun closed-sys ((w Loc)) Bool
  (or (select inVariables w) (select inDelta w)) )

;;------------------------------------------------------------------

(define-fun base ((end Loc)) Bool
(and 
(= (select n nil) nil) 
(ls end end)
(= (hls end end) empLoc ) 
(= (d end end) 0) 
(= (mkeys end end) mult-empInt)
(= (lslen end end) 0)
(= (sorted end end) true) 
(= (revsorted end end) true) 
))
(define-fun base2 ((end Loc)) Bool
(and 
(= (select n2 nil) nil) 
(ls2 end end)
(= (hls2 end end) empLoc ) 
(= (d2 end end) 0) 
(= (mkeys2 end end) mult-empInt)
(= (ls2len end end) 0)
(= (sorted2 end end) true)
(= (revsorted2 end end) true)
))
;;------------------------------------------------------------------

(define-fun n_propagate ((w Loc) (end Loc)) Bool
  (=> (not (= w end) )
  (and
    ;;true case
      (=> (ls (select n w) end)
        (and (ls w end)
        (> (d w end) (d (select n w) end)) 
        (= (hls w end) 
			 (store (hls (select n w) end) w true) )
        (= (mkeys w end) 
                (store (mkeys (select n w) end) 
				(key w) 
				(+ (select (mkeys (select n w) end) (key w)) 1)) )
        (= (lslen w end) (+ (lslen (select n w) end) 1) )
		(= (minls w end) 
		     (ite (= (select n w) end)  
			   (key w)
			   (minInt (key w) (minls (select n w) end))))
        (= (maxls w end) 
		     (ite (= (select n w) end)  
			   (key w)
			   (maxInt (key w) (maxls (select n w) end))))		
		(iff (sorted w end)
		     (and (=> (not (= (select n w) end)) (<= (key w) (key (select n w))))
	              (sorted (select n w) end) ))
        (iff (revsorted w end)
		     (and (=> (not (= (select n w) end)) (>= (key w) (key (select n w))))
	              (revsorted (select n w) end) ))
	))
    ;;false case
      (=> (not (ls (select n w) end))
        (and (not (ls w end))
             (= (hls w end) empLoc)
             (= (mkeys w end) mult-empInt)
             (= (lslen w end) -1)
		     (not (sorted w end))
             (not (revsorted w end))
    ))
  )))

(define-fun n2_propagate ((w Loc) (end Loc)) Bool
  (=> (not (= w end) )
  (and
    ;;true case
      (=> (ls2 (select n2 w) end)
        (and (ls2 w end)
        (> (d2 w end) (d2 (select n2 w) end)) 
        (= (hls2 w end) 
			 (store (hls2 (select n2 w) end) w true) )
        (= (mkeys2 w end) 
                (store (mkeys2 (select n2 w) end) 
				(key w) 
				(+ (select (mkeys2 (select n2 w) end) (key w)) 1)) )
        (= (ls2len w end) (+ (ls2len (select n2 w) end) 1) )
		(= (minls2 w end) 
		     (ite (= (select n2 w) end)  
			   (key w)
			   (minInt (key w) (minls2 (select n2 w) end)))) 
		(= (maxls2 w end) 
		     (ite (= (select n2 w) end)  
			   (key w)
			   (maxInt (key w) (maxls2 (select n2 w) end))))
        (iff (sorted2 w end)
		     (and (=> (not (= (select n2 w) end)) (<= (key w) (key (select n2 w))))
	              (sorted2 (select n2 w) end) ))
        (iff (revsorted2 w end)
		     (and (=> (not (= (select n2 w) end)) (>= (key w) (key (select n2 w))))
	              (revsorted2 (select n2 w) end) ))
	))
    ;;false case
      (=> (not (ls2 (select n2 w) end))
        (and (not (ls2 w end))
             (= (hls2 w end) empLoc)
             (= (mkeys2 w end) mult-empInt)
             (= (ls2len w end) -1)
		     (not (sorted2 w end))
             (not (revsorted2 w end))
    ))
  )))
  
;;------------------------------------------------------------------

(define-fun t_propagate ((w Loc) (end Loc)) Bool
  (=> (and (not ( select inDelta w)) (not (= w end)) )
  (and
  ;;true case 
  (=> (ls (t w) end) 
    (and (ls w end)
    (> (d w end) (d (t w) end)) 
    (= (hls w end) 
	        (union 
		      (store (hlist_measure w ) w true ) 
			  (hls (t w) end)) )
    (= (lslen w end) 
	   (+ (+ (length_measure w ) (lslen (t w) end)) 1) )
	(= (minls w end) (minInt (key w) 
		     (ite (= (t w) end)  
			   (min_measure w )
			   (minInt (min_measure w ) (minls (t w) end)))))
    (= (maxls w end) (maxInt (key w) 
		     (ite (= (t w) end)  
			   (max_measure w )
			   (maxInt (max_measure w ) (maxls (t w) end)))))
    (iff (sorted w end)
		    (and (<= (key w) (min_measure w ))
                 (sorted_measure w )
                 (=> (not (= (t w) end)) (<= (max_measure w ) (key (t w))))
                 (sorted (t w) end) )) 				 
    (iff (revsorted w end)
		    (and (>= (key w) (max_measure w ))
                 (revsorted_measure w )
                 (=> (not (= (t w) end)) (>= (min_measure w ) (key (t w))))
                 (revsorted (t w) end) )) 				 
  ))
  ;;false case
    (=> (not (ls (t w) end)) 
      (and (not (ls w end))
           (= (hls w end) empLoc)
           (= (mkeys w end) mult-empInt)
           (= (lslen w end) -1)
	       (not (sorted w end))
           (not (revsorted w end))
    ))
  )))
  
(define-fun t_propagate2 ((w Loc) (end Loc)) Bool
  (=> (and (not ( select inDelta w)) (not (= w end)) )
  (and
  ;;true case 
  (=> (ls2 (t w) end) 
    (and (ls2 w end)
    (> (d2 w end) (d2 (t w) end)) 
    (= (hls2 w end) 
	        (union 
		      (store (hlist_measure w ) w true ) 
			  (hls2 (t w) end)) )
    (= (ls2len w end) 
	   (+ (+ (length_measure w ) (ls2len (t w) end)) 1) )
	(= (minls2 w end) (minInt (key w) 
		     (ite (= (t w) end)  
			   (min_measure w )
			   (minInt (min_measure w ) (minls2 (t w) end)))))
    (= (maxls2 w end) (maxInt (key w) 
		     (ite (= (t w) end)  
			   (max_measure w )
			   (maxInt (max_measure w ) (maxls2 (t w) end)))))
    (iff (sorted2 w end)
		    (and (<= (key w) (min_measure w ))
                 (sorted_measure w )
                 (=> (not (= (t w) end)) (<= (max_measure w ) (key (t w))))
                 (sorted2 (t w) end) )) 				 	   
    (iff (revsorted2 w end)
		    (and (>= (key w) (max_measure w ))
                 (revsorted_measure w )
                 (=> (not (= (t w) end)) (>= (min_measure w ) (key (t w))))
                 (revsorted2 (t w) end) )) 				 	   
  ))
  ;;false case
    (=> (not (ls2 (t w) end)) 
      (and (not (ls2 w end))
           (= (hls2 w end) empLoc)
           (= (mkeys2 w end) mult-empInt)
           (= (ls2len w end) -1)
	       (not (sorted2 w end))
           (not (revsorted2 w end))
    ))
  )))

;;------------------------------------------------------------------
;;------------------------------------------------------------------

(declare-const key1 Int)
(declare-const num_key1@v1seg Int)
(assert (>= num_key1@v1seg 0))
(declare-const num_key1@v2seg Int)
(assert (>= num_key1@v2seg 0))
(declare-const num_key1@v3seg Int)
(assert (>= num_key1@v3seg 0))
(declare-const num_key1@v4seg Int)
(assert (>= num_key1@v4seg 0))
(declare-const num_key1@v5seg Int)
(assert (>= num_key1@v5seg 0))
(declare-const key2 Int)
(declare-const num_key2@v1seg Int)
(assert (>= num_key2@v1seg 0))
(declare-const num_key2@v2seg Int)
(assert (>= num_key2@v2seg 0))
(declare-const num_key2@v3seg Int)
(assert (>= num_key2@v3seg 0))
(declare-const num_key2@v4seg Int)
(assert (>= num_key2@v4seg 0))
(declare-const num_key2@v5seg Int)
(assert (>= num_key2@v5seg 0))
(declare-const key3 Int)
(declare-const num_key3@v1seg Int)
(assert (>= num_key3@v1seg 0))
(declare-const num_key3@v2seg Int)
(assert (>= num_key3@v2seg 0))
(declare-const num_key3@v3seg Int)
(assert (>= num_key3@v3seg 0))
(declare-const num_key3@v4seg Int)
(assert (>= num_key3@v4seg 0))
(declare-const num_key3@v5seg Int)
(assert (>= num_key3@v5seg 0))
(declare-const key4 Int)
(declare-const num_key4@v1seg Int)
(assert (>= num_key4@v1seg 0))
(declare-const num_key4@v2seg Int)
(assert (>= num_key4@v2seg 0))
(declare-const num_key4@v3seg Int)
(assert (>= num_key4@v3seg 0))
(declare-const num_key4@v4seg Int)
(assert (>= num_key4@v4seg 0))
(declare-const num_key4@v5seg Int)
(assert (>= num_key4@v5seg 0))
(declare-const key5 Int)
(declare-const num_key5@v1seg Int)
(assert (>= num_key5@v1seg 0))
(declare-const num_key5@v2seg Int)
(assert (>= num_key5@v2seg 0))
(declare-const num_key5@v3seg Int)
(assert (>= num_key5@v3seg 0))
(declare-const num_key5@v4seg Int)
(assert (>= num_key5@v4seg 0))
(declare-const num_key5@v5seg Int)
(assert (>= num_key5@v5seg 0))
(declare-const key6 Int)
(declare-const num_key6@v1seg Int)
(assert (>= num_key6@v1seg 0))
(declare-const num_key6@v2seg Int)
(assert (>= num_key6@v2seg 0))
(declare-const num_key6@v3seg Int)
(assert (>= num_key6@v3seg 0))
(declare-const num_key6@v4seg Int)
(assert (>= num_key6@v4seg 0))
(declare-const num_key6@v5seg Int)
(assert (>= num_key6@v5seg 0))
(declare-const key7 Int)
(declare-const num_key7@v1seg Int)
(assert (>= num_key7@v1seg 0))
(declare-const num_key7@v2seg Int)
(assert (>= num_key7@v2seg 0))
(declare-const num_key7@v3seg Int)
(assert (>= num_key7@v3seg 0))
(declare-const num_key7@v4seg Int)
(assert (>= num_key7@v4seg 0))
(declare-const num_key7@v5seg Int)
(assert (>= num_key7@v5seg 0))

(define-fun inKeys ((key Int)) Bool
(or
(= key key1)
(= key key2)
(= key key3)
(= key key4)
(= key key5)
(= key key6)
(= key key7)
))

(declare-const v1 Loc)
(declare-const v2 Loc)
(declare-const v3 Loc)
(declare-const v4 Loc)
(declare-const v5 Loc)

(assert (= inVariables
(store (store (store (store (store empLoc
v1 true)
v2 true)
v3 true)
v4 true)
v5 true)
))

(assert (not (select inDelta v1)))
(assert (not (select inDelta v2)))
(assert (not (select inDelta v3)))
(assert (not (select inDelta v4)))
(assert (not (select inDelta v5)))

(assert (closed-sys (t v1)) )
(assert (closed-sys (t v2)) )
(assert (closed-sys (t v3)) )
(assert (closed-sys (t v4)) )
(assert (closed-sys (t v5)) )

(define-fun t-structure-for-hls ((w Loc)) Bool
(and (not (select (hlist_measure v1 ) w ))
(and (not (select (hlist_measure v2 ) w ))
(and (not (select (hlist_measure v3 ) w ))
(and (not (select (hlist_measure v4 ) w ))
(and (not (select (hlist_measure v5 ) w ))
))))))
(assert (t-structure-for-hls v1) )
(assert (t-structure-for-hls v2) )
(assert (t-structure-for-hls v3) )
(assert (t-structure-for-hls v4) )
(assert (t-structure-for-hls v5) )

(assert (t_structure_for_sorted_measure v1))
(assert (t_structure_for_sorted_measure v2))
(assert (t_structure_for_sorted_measure v3))
(assert (t_structure_for_sorted_measure v4))
(assert (t_structure_for_sorted_measure v5))

(assert (hls_separate v1 v2))
(assert (hls_separate v1 v3))
(assert (hls_separate v1 v4))
(assert (hls_separate v1 v5))
(assert (hls_separate v2 v3))
(assert (hls_separate v2 v4))
(assert (hls_separate v2 v5))
(assert (hls_separate v3 v4))
(assert (hls_separate v3 v5))
(assert (hls_separate v4 v5))

(assert (=> (= (hlist_measure v1) empLoc) (= (length_measure v1) 0)))
(assert (=> (= (hlist_measure v2) empLoc) (= (length_measure v2) 0)))
(assert (=> (= (hlist_measure v3) empLoc) (= (length_measure v3) 0)))
(assert (=> (= (hlist_measure v4) empLoc) (= (length_measure v4) 0)))
(assert (=> (= (hlist_measure v5) empLoc) (= (length_measure v5) 0)))

(assert (<= (min_measure v1) key1))
(assert (<= (min_measure v1) key2))
(assert (<= (min_measure v1) key3))
(assert (<= (min_measure v1) key4))
(assert (<= (min_measure v1) key5))
(assert (<= (min_measure v1) key6))
(assert (<= (min_measure v1) key7))
(assert (>= (max_measure v1) key1))
(assert (>= (max_measure v1) key2))
(assert (>= (max_measure v1) key3))
(assert (>= (max_measure v1) key4))
(assert (>= (max_measure v1) key5))
(assert (>= (max_measure v1) key6))
(assert (>= (max_measure v1) key7))
(assert (<= (min_measure v2) key1))
(assert (<= (min_measure v2) key2))
(assert (<= (min_measure v2) key3))
(assert (<= (min_measure v2) key4))
(assert (<= (min_measure v2) key5))
(assert (<= (min_measure v2) key6))
(assert (<= (min_measure v2) key7))
(assert (>= (max_measure v2) key1))
(assert (>= (max_measure v2) key2))
(assert (>= (max_measure v2) key3))
(assert (>= (max_measure v2) key4))
(assert (>= (max_measure v2) key5))
(assert (>= (max_measure v2) key6))
(assert (>= (max_measure v2) key7))
(assert (<= (min_measure v3) key1))
(assert (<= (min_measure v3) key2))
(assert (<= (min_measure v3) key3))
(assert (<= (min_measure v3) key4))
(assert (<= (min_measure v3) key5))
(assert (<= (min_measure v3) key6))
(assert (<= (min_measure v3) key7))
(assert (>= (max_measure v3) key1))
(assert (>= (max_measure v3) key2))
(assert (>= (max_measure v3) key3))
(assert (>= (max_measure v3) key4))
(assert (>= (max_measure v3) key5))
(assert (>= (max_measure v3) key6))
(assert (>= (max_measure v3) key7))
(assert (<= (min_measure v4) key1))
(assert (<= (min_measure v4) key2))
(assert (<= (min_measure v4) key3))
(assert (<= (min_measure v4) key4))
(assert (<= (min_measure v4) key5))
(assert (<= (min_measure v4) key6))
(assert (<= (min_measure v4) key7))
(assert (>= (max_measure v4) key1))
(assert (>= (max_measure v4) key2))
(assert (>= (max_measure v4) key3))
(assert (>= (max_measure v4) key4))
(assert (>= (max_measure v4) key5))
(assert (>= (max_measure v4) key6))
(assert (>= (max_measure v4) key7))
(assert (<= (min_measure v5) key1))
(assert (<= (min_measure v5) key2))
(assert (<= (min_measure v5) key3))
(assert (<= (min_measure v5) key4))
(assert (<= (min_measure v5) key5))
(assert (<= (min_measure v5) key6))
(assert (<= (min_measure v5) key7))
(assert (>= (max_measure v5) key1))
(assert (>= (max_measure v5) key2))
(assert (>= (max_measure v5) key3))
(assert (>= (max_measure v5) key4))
(assert (>= (max_measure v5) key5))
(assert (>= (max_measure v5) key6))
(assert (>= (max_measure v5) key7))

(define-fun mkeys_propagate_for_vars ((end Loc)) Bool
(and
(=> (and (ls (t v1) end) (not (select inDelta v1)) (not (= v1 end)))(= (mkeys v1 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v1) 1)
key1 num_key1@v1seg)
key2 num_key2@v1seg)
key3 num_key3@v1seg)
key4 num_key4@v1seg)
key5 num_key5@v1seg)
key6 num_key6@v1seg)
key7 num_key7@v1seg)
(mkeys (t v1) end) )))

(=> (and (ls (t v2) end) (not (select inDelta v2)) (not (= v2 end)))(= (mkeys v2 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v2) 1)
key1 num_key1@v2seg)
key2 num_key2@v2seg)
key3 num_key3@v2seg)
key4 num_key4@v2seg)
key5 num_key5@v2seg)
key6 num_key6@v2seg)
key7 num_key7@v2seg)
(mkeys (t v2) end) )))

(=> (and (ls (t v3) end) (not (select inDelta v3)) (not (= v3 end)))(= (mkeys v3 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v3) 1)
key1 num_key1@v3seg)
key2 num_key2@v3seg)
key3 num_key3@v3seg)
key4 num_key4@v3seg)
key5 num_key5@v3seg)
key6 num_key6@v3seg)
key7 num_key7@v3seg)
(mkeys (t v3) end) )))

(=> (and (ls (t v4) end) (not (select inDelta v4)) (not (= v4 end)))(= (mkeys v4 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v4) 1)
key1 num_key1@v4seg)
key2 num_key2@v4seg)
key3 num_key3@v4seg)
key4 num_key4@v4seg)
key5 num_key5@v4seg)
key6 num_key6@v4seg)
key7 num_key7@v4seg)
(mkeys (t v4) end) )))

(=> (and (ls (t v5) end) (not (select inDelta v5)) (not (= v5 end)))(= (mkeys v5 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v5) 1)
key1 num_key1@v5seg)
key2 num_key2@v5seg)
key3 num_key3@v5seg)
key4 num_key4@v5seg)
key5 num_key5@v5seg)
key6 num_key6@v5seg)
key7 num_key7@v5seg)
(mkeys (t v5) end) )))

))
(define-fun mkeys2_propagate_for_vars ((end Loc)) Bool
(and
(=> (and (ls2 (t v1) end) (not (select inDelta v1)) (not (= v1 end)))(= (mkeys2 v1 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v1) 1)
key1 num_key1@v1seg)
key2 num_key2@v1seg)
key3 num_key3@v1seg)
key4 num_key4@v1seg)
key5 num_key5@v1seg)
key6 num_key6@v1seg)
key7 num_key7@v1seg)
(mkeys2 (t v1) end) )))

(=> (and (ls2 (t v2) end) (not (select inDelta v2)) (not (= v2 end)))(= (mkeys2 v2 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v2) 1)
key1 num_key1@v2seg)
key2 num_key2@v2seg)
key3 num_key3@v2seg)
key4 num_key4@v2seg)
key5 num_key5@v2seg)
key6 num_key6@v2seg)
key7 num_key7@v2seg)
(mkeys2 (t v2) end) )))

(=> (and (ls2 (t v3) end) (not (select inDelta v3)) (not (= v3 end)))(= (mkeys2 v3 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v3) 1)
key1 num_key1@v3seg)
key2 num_key2@v3seg)
key3 num_key3@v3seg)
key4 num_key4@v3seg)
key5 num_key5@v3seg)
key6 num_key6@v3seg)
key7 num_key7@v3seg)
(mkeys2 (t v3) end) )))

(=> (and (ls2 (t v4) end) (not (select inDelta v4)) (not (= v4 end)))(= (mkeys2 v4 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v4) 1)
key1 num_key1@v4seg)
key2 num_key2@v4seg)
key3 num_key3@v4seg)
key4 num_key4@v4seg)
key5 num_key5@v4seg)
key6 num_key6@v4seg)
key7 num_key7@v4seg)
(mkeys2 (t v4) end) )))

(=> (and (ls2 (t v5) end) (not (select inDelta v5)) (not (= v5 end)))(= (mkeys2 v5 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v5) 1)
key1 num_key1@v5seg)
key2 num_key2@v5seg)
key3 num_key3@v5seg)
key4 num_key4@v5seg)
key5 num_key5@v5seg)
key6 num_key6@v5seg)
key7 num_key7@v5seg)
(mkeys2 (t v5) end) )))

))
(define-fun t_propagate_for_vars ((end Loc)) Bool
(and (mkeys_propagate_for_vars end)
(and (t_propagate v1 end)
(and (t_propagate v2 end)
(and (t_propagate v3 end)
(and (t_propagate v4 end)
(and (t_propagate v5 end)
)))))))

(define-fun t_propagate2_for_vars ((end Loc)) Bool
(and (mkeys2_propagate_for_vars end)
(and (t_propagate2 v1 end)
(and (t_propagate2 v2 end)
(and (t_propagate2 v3 end)
(and (t_propagate2 v4 end)
(and (t_propagate2 v5 end)
)))))))

;;-----------------------------------------------------------
;;-----------------------------------------------------------

;;copyall(x): copies x into y
;;declare x
(declare-const x Loc)
(assert (inKeys (key x)))
(assert (closed-sys x) )

;;declare temp_x
(declare-const temp_x Loc)
(assert (inKeys (key temp_x)))
(assert (closed-sys temp_x) )
;;declare temp_y
(declare-const temp_y Loc)
(assert (inKeys (key temp_y)))
(assert (closed-sys temp_y) )

(declare-const oldhls (Set Loc))
(declare-const oldmkeys (MultiSet Int))

(push)
;;assume x == nil
(assert (= x nil))
;;declare y
(declare-const y Loc)
(assert (inKeys (key y)))
(assert (closed-sys y) )
;;y = nil
(assert (= y nil))
;;return y

;;--delta is nothing
(assert (= inDelta empLoc))

;@precondition: list(x)
;;&& mkeys(x, nil) = oldmkeys && hls(x, nil) = oldhls
(assert (and 
(ls x nil)
(= (mkeys x nil) oldmkeys)
(= (hls x nil) oldhls)
))
(assert (base nil))
(assert (t_propagate_for_vars nil) )

;negate@list(y) && mkeys(x, nil) = mkeys(y, nil)
;;&& mkeys(x, nil) = oldmkeys && hls(x, nil) = oldhls
;;&& hls(x, nil) \intersect hls(y, nil) = \empty
(assert (not (and 
(ls y nil)
(= (mkeys x nil) (mkeys y nil))
(= (mkeys x nil) oldmkeys)
(= (hls x nil) oldhls)
(= (intersect (hls x nil) (hls y nil)) empLoc)
)))
(check-sat)
(get-model)
(pop)

(push)
;@assume x =/= nil
(assert (not (= x nil)))
;;ensure created y =/= nil
;;declare y
(declare-const y Loc)
(assert (inKeys (key y)))
(assert (not (closed-sys y)) )
(assert (not (= y nil)))
;;temp_x = x.next
(assert (= temp_x (select n x)) )
;;y.key = x.key
(assert (= (key y) (key x)) )
;;y.next = nil
(assert (= (select n y) nil) )
;;temp_y = y
(assert (= temp_y y) )

;;--delta is x and y
(assert (= inDelta
(store (store empLoc 
x true)
y true)
))
(assert (closed-sys (select n x)) )
(assert (t-structure-for-hls x) )
(assert (closed-sys (select n y)) )
(assert (t-structure-for-hls y) )

;@precondition: list(x)
;;&& mkeys(x, nil) = oldmkeys && hls(x, nil) = oldhls
(assert (and 
(ls x nil)
(= (mkeys x nil) oldmkeys)
(= (hls x nil) oldhls)
))

;negate@ls(x, nil) && ls(x, temp_x) && ls(y, temp_y) && temp_y.next = nil  
;; && mkeys(x, nil) = mkeys(temp_x, nil) \mult-union mkeys(y, nil)
;;&& mkeys(x, nil) = oldmkeys && hls(x, nil) = oldhls
;;&& hls(x, nil) \intersect hls(y, nil) = \empty
(assert (not (and 
(ls x nil)
(ls x temp_x)
(ls y temp_y)
(= (select n temp_y) nil)
(= (mkeys x nil) (mult-union (mkeys temp_x nil) (mkeys y nil))) 
(= (mkeys x nil) oldmkeys)
(= (hls x nil) oldhls)
(= (intersect (hls x nil) (hls y nil)) empLoc)
)))
(assert (base nil) )
(assert (n_propagate x nil) )
(assert (n_propagate y nil) )
(assert (t_propagate_for_vars nil) )

(assert (base temp_x) )
(assert (n_propagate x temp_x) )
(assert (n_propagate y temp_x) )
(assert (t_propagate_for_vars temp_x) )

(assert (base temp_y) )
(assert (n_propagate x temp_y) )
(assert (n_propagate y temp_y) )
(assert (t_propagate_for_vars temp_y) )
(check-sat)
(get-model)
(pop)

(push)
;;declare y
(declare-const y Loc)
(assert (inKeys (key y)))
(assert (closed-sys y) )

;;while temp_x =/= nil
(assert (not (= temp_x nil)) )
;;create new_y
(declare-const new_y Loc)
(assert (inKeys (key new_y)))
;;new_y.key = temp_x.key
(assert (= (key new_y) (key temp_x)) )
;;new_y.next = nil
;;temp_y.next = new_y
(assert (= n2 (store (store n new_y nil) temp_y new_y) ))
;;temp_y = new_y
(declare-const temp_y2 Loc)
(assert (= temp_y2 new_y))
;;temp_x = temp_x.next
(declare-const temp_x2 Loc)
(assert (inKeys (key temp_x2)))
(assert (= temp_x2 (select n2 temp_x)))

;;--delta is temp_x and temp_y
(assert (= inDelta
(store (store empLoc 
temp_x true)
temp_y true)
))
(assert (closed-sys (select n temp_y)) )
(assert (t-structure-for-hls temp_y) )
(assert (closed-sys (select n temp_x)) )
(assert (t-structure-for-hls temp_x) )

;;--new delta is new_y
(assert (not (closed-sys new_y)) )
(assert (t-structure-for-hls new_y) )

;@ ls(x, nil) && ls(x, temp_x) && ls(y, temp_y) && temp_y.next = nil  
;; && mkeys(x, nil) = mkeys(temp_x, nil) \mult-union mkeys(y, nil)
;;&& mkeys(x, nil) = oldmkeys && hls(x, nil) = oldhls
;;&& hls(x, nil) \intersect hls(y, nil) = \empty
(assert (and 
(ls x nil)
(ls x temp_x)
(ls y temp_y)
(= (select n temp_y) nil)
(= (mkeys x nil) (mult-union (mkeys temp_x nil) (mkeys y nil))) 
(= (mkeys x nil) oldmkeys)
(= (hls x nil) oldhls)
(= (intersect (hls x nil) (hls y nil)) empLoc)
))
(assert (base nil) )
(assert (n_propagate temp_x nil) )
(assert (n_propagate temp_y nil) )
(assert (t_propagate_for_vars nil) )

(assert (base temp_x) )
(assert (n_propagate temp_x temp_x) )
(assert (n_propagate temp_y temp_x) )
(assert (t_propagate_for_vars temp_x) )

(assert (base temp_y) )
(assert (n_propagate temp_x temp_y) )
(assert (n_propagate temp_y temp_y) )
(assert (t_propagate_for_vars temp_y) )
 
;negate@ls(x, nil) && ls(x, temp_x) && ls(y, temp_y) && temp_y.next = nil  
;; && mkeys(x, nil) = mkeys(temp_x, nil) \mult-union mkeys(y, nil)
;;&& mkeys(x, nil) = oldmkeys && hls(x, nil) = oldhls
;;&& hls(x, nil) \intersect hls(y, nil) = \empty
(assert (not (and 
(ls2 x nil)
(ls2 x temp_x2)
(ls2 y temp_y2)
(= (select n2 temp_y2) nil)
(= (mkeys2 x nil) (mult-union (mkeys2 temp_x2 nil) (mkeys2 y nil))) 
(= (mkeys2 x nil) oldmkeys)
(= (hls2 x nil) oldhls)
(= (intersect (hls2 x nil) (hls2 y nil)) empLoc)
)))
(assert (base2 nil) )
(assert (n2_propagate temp_x nil))
(assert (n2_propagate temp_y nil))
(assert (n2_propagate new_y nil))
(assert (t_propagate2_for_vars nil))

(assert (base2 temp_x2) )
(assert (n2_propagate temp_x temp_x2))
(assert (n2_propagate temp_y temp_x2))
(assert (n2_propagate new_y temp_x2))
(assert (t_propagate2_for_vars temp_x2))

(assert (base2 temp_y2) )
(assert (n2_propagate temp_x temp_y2))
(assert (n2_propagate temp_y temp_y2))
(assert (n2_propagate new_y temp_y2))
(assert (t_propagate2_for_vars temp_y2))
(check-sat)
(get-model)
(pop)

;;end-of-while
(push)
;;declare y
(declare-const y Loc)
(assert (inKeys (key y)))
(assert (closed-sys y) )
(assert (= temp_x nil))

;;--delta is temp_y
(assert (= inDelta
(store empLoc 
temp_y true)
))

(assert (closed-sys (select n temp_y)) )
(assert (t-structure-for-hls temp_y) )

;@ls(x, nil) && ls(x, temp_x) && ls(y, temp_y) && temp_y.next = nil  
;; && mkeys(x, nil) = mkeys(temp_x, nil) \mult-union mkeys(y, nil)
;;&& mkeys(x, nil) = oldmkeys && hls(x, nil) = oldhls
;;&& hls(x, nil) \intersect hls(y, nil) = \empty
(assert (and 
(ls x nil)
(ls x temp_x)
(ls y temp_y)
(= (select n temp_y) nil)
(= (mkeys x nil) (mult-union (mkeys temp_x nil) (mkeys y nil))) 
(= (mkeys x nil) oldmkeys)
(= (hls x nil) oldhls)
(= (intersect (hls x nil) (hls y nil)) empLoc)
))		
(assert (base nil) )
(assert (n_propagate temp_y nil) )
(assert (t_propagate_for_vars nil) )
(assert (base temp_x) )
(assert (n_propagate temp_y temp_x) )
(assert (t_propagate_for_vars temp_x) )
(assert (base temp_y) )
(assert (n_propagate temp_y temp_y) )
(assert (t_propagate_for_vars temp_y) )

;negate@list(y) && mkeys(x, nil) = mkeys(y, nil)
;;&& mkeys(x, nil) = oldmkeys && hls(x, nil) = oldhls
;;&& hls(x, nil) \intersect hls(y, nil) = \empty
(assert (not 
(and (ls y nil)
(= (mkeys x nil) (mkeys y nil))
(= (mkeys x nil) oldmkeys)
(= (hls x nil) oldhls)
(= (intersect (hls x nil) (hls y nil)) empLoc)
)))
(check-sat)
(get-model)
(pop)