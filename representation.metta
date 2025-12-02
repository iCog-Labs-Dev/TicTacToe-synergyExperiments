!(import! &self ./utils)

;; ;; Winning states.
;;
;; (Board ($a $b $c
;;         $d $a $f
;;         $g $h $a))
;;
;; (Board ($a $a $a
;;         $d $e $f
;;         $g $h $i))
;;
;; (Board ($a $b $c
;;         $a $e $f
;;         $a $h $i))
;;
;; (Board ($a $b $c
;;         $d $b $f
;;         $g $b $i))
;;
;; (Board ($a $b $c
;;         $d $e $c
;;         $g $h $c))
;;
;; (Board ($a $b $c
;;         $d $c $f
;;         $c $h $i))
;;
;; (Board ($a $b $c
;;         $d $d $d
;;         $g $h $i))
;;
;; (Board ($a $b $c
;;         $d $e $f
;;         $g $g $g))

;; (Board ($a $b $c $d $e $f $g $h $i))

(Board (X  X  X
        $d $e $f
        $g $h $i))

(Board (X $b $c
        X $e $f
        X $h $i))

(Board (X $b $c
        $d X $f
        $g $h X))

(Board ($a X $c
        $d X $f
        $g X $i))

(Board ($a $b X
        $d $e X
        $g $h X))

(Board ($a $b X
        $d X $f
        X $h $i))

(Board ($a $b $c
         X  X  X
        $g $h $i))

(Board ($a $b $c
        $d $e $f
         X  X  X))


(= (unify $a $b $t $f) (if (= $a $b) $t $f))

;; Takes a game state example (Board (X E X E O E E O E)) and returns 1 meaning this state is one change away from becoming a winning state at minimum.
;; It can also take a game state of (Board (X E E E O E E E E)) and it returns 2 meaning this state is two changes away from becoming a winning.

;; (Board (X E E E O E E E E))
;; (Board (X X X $ O $ $ $ $))

(= (replace-atom $a $index $expression)
  (if (== $expression ())
      ()
      (let ($h $t) (decons-atom $expression)
           (if (== $index 0)
               (cons-atom $a $t)
               (let $res (replace-atom $a (- $index 1) $t) (cons-atom $h $res))))))

!(bind! &count (new-state 0))

(= (mkVar $a $n) (if (== $a E) (index-atom 
                                  ($1 $2 $3 $4 $5 $6 $7 $8 $9 
                                   $10 $11 $12 $13 $14 $15 $16 $17 $18 $19
                                   $20 $21 $22 $23 $24 $25 $26 $27 $28 $29
                                   $30 $31 $32 $33 $34 $35 $36 $37 $38 $39
                                   $40 $41 $42 $43 $44 $45 $46 $47 $48 $49
                                   $50 $51 $52 $53 $54 $55 $56 $57 $58 $59
                                   $60 $61 $62 $63 $64 $65 $66 $67 $68 $69
                                   $70 $71 $72 $73 $74 $75 $76 $77 $78 $79
                                   $80 $81 $82 $83 $84 $85 $86 $87 $88 $89
                                   $90 $91 $92 $93 $94 $95 $96 $97 $98 $99 $100
                                   ) $n) $a))

(= (createQuery (Board $a)) (let $result (Board (zipWith mkVar $a (range (get-state &count) (+ (get-state &count) (+ (size-atom $a) 1))))) (let $_ (change-state! &count (+ (get-state &count) (+ (size-atom $a) 1)) ) $result)))

(= (hammingDistance (Board $a) (Board $b))  (hammingDistance (Board $a) (Board $b) 0 0))
(= (hammingDistance (Board $a) (Board $b) $current $count)
   (if (or (= $a $b) (== $current (size-atom $a)))
       (py-call (float "inf"))
       (let*
          (
            ($index (index-atom $a $current))
            ($a' (if (== $index E) (replace-atom X $current $a) $a))
            )
          (hammingDistance (Board $a') (Board $b) (+ $current 1) (if (== $a' $a) $count (+ $count 1))))))

(= (nextMoves (Board $a) $mark)
   (collapse 
      (let $indices (map-atom
                       (filter-atom
                          (zip $a (range 0 (size-atom $a)))
                          (compose (== E) (first-from-pair)))
                       second-from-pair)
        (Board (replace-atom $mark (superpose $indices) $a)))))

(= (getQueries $currentState $mark)
   (collapse (let*
                (
                  ($nextMoves (nextMoves $currentState $mark))
                  ($nextMove (superpose $nextMoves))
                  ($_ (println! (NextMove: $nextMove)))
                  ($query (createQuery $nextMove))
                  ($_ (println! (Query: $query)))
                )
                $query)))

(= (getValidWinningMoves $currentQuery) (trace! (Running Query $currentQuery) (collapse (match &self $currentQuery $currentQuery))))

!(let*
    (
      ($queries (getQueries (Board (E E E E E E E E E)) X))
      ;; ($queries (getQueries (Board (E E E E E E E E E)) X))
      ($query (superpose $queries))
      ;; ($_ (println! (Query: $query)))
      ($winningMoves (match &self $query $query))
    )
    ($winningMoves))

;; !(getQueries (Board (E E E E E E E E E)) X)

;; !(range 0 (size-atom (X E E E O E E E E)))
;; !(compose (== E) (first-from-pair) (E 1))
;; !(zip (X E E E O E E E E) (range 0 (size-atom (X E E E O E E E E))))
;; !(filter-atom (zip (X E E E O E E E E) (range 0 (size-atom (X E E E O E E E E)))) (compose (== E) (first-from-pair)))
;; !(nextMoves (Board (X E E E O E E E E)) X)
;; !(range 1 3)
;; !(zipWith mkVar (X E E E O E E E E) (1 2 3 4 5 6 7 8 9))
;; !(zipWith + (1 2 3 4) (5 6 7 8))
;; !(createQuery (Board (X E E E O E E E E)))
;; !(createQuery (Board (X E E E O E E E E)))
;; !(createQuery (Board (X E E E O E E E E)))
;; !(mkVar E 1)
;; !(selectionSort (1 5 3 4) (size-atom (1 2 3 4)) (comp >))
;; !(selection (max <=) 5 (1 2 3 4 5 6 6 7 8 9))
;; !(subtraction-atom (1 1 2 3 4) (1))
;; !(exclude-item 1 (1 1 2 3 4))
;; !(max 1 2 >)
;; !(max-atom (1 2 3 4) <)
;; !(foldleft < (2 3 4) 1)
;; !(foldl + (cdr-atom (1 2 3 4)) (car-atom (1 2 3 4)))
;; !(hammingDistance (Board (X E E E O E E E E)) (collapse (match &self (Board (X $b $c $d O $f $g $h $i)) (Board (X $b $c $d O $f $g $h $i)))))
;; !(index-atom (A B C) 1)
;; !(replace-atom B 0 (A B C))
;; !(changeUntilUnify (Board (X E E E O E E E E)) (Board (X X X $a O $b $c $d $e)))
;; !(foldl + (1 2 3 4) 0)
