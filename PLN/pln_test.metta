!(import! &self pln)

!(bind! &perception (new-space))
!(bind! &belief (new-space))
!(bind! &count (new-state 39))


!((collapse (let $perception
      (superpose
        (
          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E)))))
          (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E))))
          (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E))))
          (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E))))
          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E)))))
          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E)))))
          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E)))))
          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E)))))
        ) ;; Manually inputed space content. It should be updated to be persistent.
      )
      (add-atom &perception $perception)))



(collapse (let $belief
      (superpose
        (
            (Sentence ((Implication (Implication (Board $1 $1s) (Board $2 $2s)) (Implication (Inheritance (Board $2 $2s) (GameWin $winner)) (Inheritance (Board $1 $1s) (GameWin $winner)))) (stv 0.9 0.9)) (0))
            ;; (Sentence ((Equivalence (Board (Row $TL (Col $TC $TR)) (Rows (Row $ML (Col $MC $MR)) (Row $BL (Col $BC $BR)))) (Board (Row $TR (Col $TC $TL)) (Rows (Row $MR (Col $MC $ML)) (Row $BR (Col $BC $BL))))) (stv 0.9 0.9)) (4))
            ;; (Sentence ((Equivalence (Board $TopRow (Rows $MidRow $BotRow)) (Board $BotRow (Rows $MidRow $TopRow))) (stv 0.9 0.9)) (5))


            (Sentence ((Inheritance (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E)))) (GameWin O)) (stv 0.9 0.9)) (144))
            (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))) (stv 0.7 0.8)) (201))
            (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))) (stv 0.6 0.8)) (202))
            (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))) (stv 0.5 0.8)) (203))
            (Sentence ((Implication (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E))))) (stv 0.4 0.8)) (204))
            (Sentence ((Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E))))) (stv 0.3 0.8)) (205))
            (Sentence ((Implication (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))) (Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E))))) (stv 0.2 0.8)) (206))
            (Sentence ((Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (stv 0.5 0.8)) (207))
            (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (stv 0.5 0.8)) (208))
            (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (stv 0.5 0.8)) (209))
            (Sentence ((Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (stv 0.5 0.8)) (210))
            (Sentence ((Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))) (stv 0.5 0.8)) (211))
            (Sentence ((Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row X (Col E E)))) (stv 0.5 0.8)) (212))
            (Sentence ((Board (Row X (Col E X)) (Rows (Row O (Col O O)) (Row X (Col E E)))) (stv 0.5 0.8)) (213))

           ;; Moked moves
        ) ;; Manually inputed space content. It should be updated to be persistent.
      )
      (add-atom &belief $belief))))

(= (STV $fact)
          (let*
            (
              ;; ($_ (println! (Calling STV for $fact)))
              ($m (foldl-atom (if (= $fact ($link $a $b)) (collapse (match &perception $fact 1)) (collapse (match &perception ($link $a $fact) 1))) 0 +)) ;; Positive count
              ($N (foldl-atom (collapse (match &perception $x 1)) 0 +)) ;; Total count
              ;; ($_ (println! (Found M: $m and N: $N)))
              ;; ($_ (println! ""))
            )
            (stv (/ $m $N) (/ $N (+ $N (K)))))
          )

(= (increment $state) (let $n (get-state $state) (let $_ (change-state! $state (+ $n 1)) (get-state $state))))
(= (update-atom $space $old $new) (match $space $old (let $_ (remove-atom $space $old) (add-atom $space $new))))

(= (populate-belief $atoms)
   (let*
      (
        ($updatedPercept' (collapse (let $percept (superpose $atoms) ($percept (STV $percept)))))
        ($updatedPercept (unique-atom $updatedPercept'))
        ($revisedPercepts (collapse (let*
               (
                 (($percept $stvN) (superpose $updatedPercept))
                 ((Sentence ($percept $stv) $Ev) (get-atoms &belief))
                 ((Sentence ($percept $stvU) $Ev) (BestCandidate PriorityRank () (collapse (|- ($percept $stv) ($percept $stvN)))))
                 ($_ (update-atom &belief (Sentence ($percept $stv) $Ev) (Sentence ($percept $stvU) $Ev)))
               )
               $percept)))
        ($revisedPercepts' (unique-atom $revisedPercepts))
        ($newBeliefs (subtraction-atom $updatedPercept $revisedPercepts'))
        ($_ (collapse (let*
                         (
                           (($percept $stvN) (superpose $newBeliefs))
                           ($i (increment &count))
                         )
                         (add-atom &belief (Sentence ($percept $stvN) ($i))))))
      )
      (get-atoms &belief))
)

;; !(populate-belief (get-atoms &perception))
;; !(STV Game_Win_O)


;; INFO: For a new move:
;;     - If it has a small stv value randomly assigned with MOSES, it has a chance of not being selected and get truncated everytime. Therefore the number should be higher. 
;;     - Not both the strength and the confidence have to be higher, the confidence is the most determining factor here. For some reason if the confidence is too low, it will be truncated. We can mitigate this by increasing the step size but it is not reliable. For comparison, with iteration 500 and task size of 500, it can't find reliable results when K > 66 but for 1000 step size keeping task size the same, it can support all the way upto 700.
;;     - If the outcome of the move isn't known for sure, because PLN hasn't seen it before hand, then this will be a problem so defaulting to what the next most popular move is should be considered.
;;     - We need to populate the implication links in the space after MOSES has generated it's candidates, and if it can not find moves that are not being repeated, it will just give all moves the same weight kind of like uniform randomness.
;;     - Adding single board state moves will also be needed for computing STV values for a single game.
;;     - If you change the pln to check with unification instead of equality, can query for the next best move but with the risk of generating an invalid move. Not that it matters a lot though. Because the invalid move will most likely have a lower stv value so you can filter it out. But it can still turn up if the exact generalized rule can be matched. Unless there's a way to deal with that, it is best to stick with the concrete query, or atleast as concrete as possible. (This is happening by matching the move on its self and succeeding the unification hence being returned)
;;
; !(let* (
;          ($query (Inheritance (Board (Row X (Col E E))
;                                (Rows (Row E (Col E E))
;                                      (Row E (Col E E)))) Game_Win_X))
;          ($Nothing (collapse (let $result  (PLN.Query (kb1) $query 700 100 700) (add-atom &space $result))))
;       )
;       (println! (match &space (Sentence ($query $stv) $proof) (Sentence ($query $stv) $proof)))
; )


;; !(= (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X)))) (Board (Row X (Col $a O)) (Rows (Row $b (Col X O)) (Row $c (Col $d $e)))))
;; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Board (Row O (Col E X)) (Rows (Row O (Col X E)) (Row E (Col E E))))) Game_Win_X) 500 200 500)

;; Winning move
;; !(println! (First move score)) ;; 1 2 4
;; !(let*
;;    (
;;       (($bestCandidate $belief) (PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row X (Col E X)))) Game_Win_X) 400 200 300))
;;       ;; (($bestCandidate $belief) (PLN.Query (collapse (get-atoms &belief)) (Implication (Board (Row E (ColE E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E X))))) 400 200 300))
;;       ;; ($_ (println! (Best Candidate STV: $bestCandidate)))
;;       ;; ($beliefs (collapse (populate-belief $belief)))
;;    )
;;    $bestCandidate)
;; !(println! (First move score)) ;; 1 2 4
;; !(println! "Hello")
;; !(PLN.Query (collapse (get-atoms &belief)) (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col $b $c)) (Rows (Row $d (Col $a $e)) (Row $f (Col $g $h))))) 2000 500 2000)

;; !(PLN.Query (collapse (get-atoms &belief)) (Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))) 200 100 200)

; !(println! (Second move score))
;; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col X E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Third move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E X)) (Rows (Row E (Col E E)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Fourth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row X (Col E E)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Fifth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col X E)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Sixth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col E X)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Seventh move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row X (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Eigth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col X E)))) Game_Win_X) 200 100 200)

; !(println! (Ninth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E X)))) Game_Win_X) 200 100 200)


;; Most common move
;; !(println! (First move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E X))))) 1000 500 1000)
;;
;; !(println! (Second move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col X E))))) 1000 500 1000)
;;
;; !(println! (Third move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row X (Col E E))))) 1000 500 1000)
;;
;; !(println! (Fourth move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O X)) (Row E (Col E E))))) 1000 500 1000)
;;
;; !(println! (Fifth move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row X (Col O E)) (Row E (Col E E))))) 1000 500 1000)
;;
;; !(println! (Sixth move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))) 1000 500 1000)
;;
;; !(println! (Seventh move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E #))))) 1000 500 1000)
;; TODO:
;;   - STV value being greater than 1
;;   - Results that should be found aren't being found. E.g. (Inheritance (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E)))) Game_Win_X)

;; !(py-call (random.seed 344))

;; !(PLN.Query (collapse (get-atoms &belief)) (Implication (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E)))) (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X))))) 300 500 300) ;; Works with PriorityRank
;; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X)))) Game_Win_X) 25 2 125) ;; Works with PriorityRank
;; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E)))) Game_Win_X) 300 500 300) ;; Works with PriorityRank

;; !(|- ((Inheritance (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X)))) Game_Win_X) (stv 0.9 0.9)) ((Inheritance (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X)))) Game_Win_X) (stv 0.9 0.9))) ;; WARN: Use as a testcase, it used to fail on seed 0. It used to return strength value of greater than 1. More specifically 1.62 something.

(= (findSeed $p $f $n)
   (let*
      (
        ($_ (println! (Trying Seed: $n)))
        ($_ (println! ""))
        ($_ (py-call (random.seed $n)))
        ;; ($_ (py-call (time.sleep 1)))
        ($result (eval $f) )
        ($_ (println! ""))
      )
      (if ($p $result)
          $n
          (findSeed $p $f (+ $n 1)))))

;; !(findSeed (!= ()) (quote (PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E)))) Game_Win_X) 25 2 125)) 100)
;; !(findSeed 146) ;; WARN: This is a failing seed. It generates an STV value of greater than 1.


;; !(BestCandidate ThompsonRank () (collapse (get-atoms &belief)))
;; !(BestCandidate PriorityRank () (collapse (get-atoms &belief)))
;; !(BestCandidate BayesianRank () (collapse (get-atoms &belief)))

(= (until $p $f) (let $res (eval $f)
                      (if ($p $res)
                          $res
                          (until $p $f))))

;; !(until (= (Sentence ((Implication (Implication (Board $_425910 $_425916) (Board $_425934 $_425940)) (Implication (Inheritance (Board $_425934 $_425940) Game_Win_X) (Inheritance (Board $_425910 $_425916) Game_Win_X))) (stv 0.9 0.9)) (0))) (quote (BestCandidate ThompsonRank () (collapse (get-atoms &belief)))))

;; !(findSeed (= (Sentence ((Implication (Implication (Board $_425910 $_425916) (Board $_425934 $_425940)) (Implication (Inheritance (Board $_425934 $_425940) Game_Win_X) (Inheritance (Board $_425910 $_425916) Game_Win_X))) (stv 0.9 0.9)) (0))) (quote (BestCandidate ThompsonRank () (collapse (get-atoms &belief)))) 0)


;; !(STV Truth_Deduction Game_Lose_X)
;; !(Truth_Deduction (STV Truth_Deduction Game_Lose_X) (STV Truth_Deduction (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E))))) (STV Truth_Deduction Game_Win_O) (stv 0.812 0.015359999999999997) (stv 0.9 0.9)) ;; WARN: Use as a testcase, it used to fail on seed 1

;; !(PLN.Query (collapse (get-atoms &belief)) (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board $row $rows)) 20 30 20) ;; Works but only if the parameter is high. This is required if the state is not directly linked with the winning state.
;; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row X (Col E X)) (Rows (Row O (Col O E)) (Row E (Col E E)))) (GameWin O)) 800 300 800)
