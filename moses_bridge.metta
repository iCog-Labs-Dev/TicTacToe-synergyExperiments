;; Imports for MOSES Strategy Evolution
!(import! &self ./metta-moses/representation/lsk)
!(import! &self ./metta-moses/representation/instance)
!(import! &self ./metta-moses/representation/build-knobs)
!(import! &self ./metta-moses/representation/knob-mapper)
!(import! &self ./metta-moses/representation/logical-probe)
!(import! &self ./metta-moses/representation/build-logical)
!(import! &self ./metta-moses/representation/representation)
!(import! &self ./metta-moses/representation/add-logical-knobs)
!(import! &self ./metta-moses/representation/knob-representation)
!(import! &self ./metta-moses/representation/sample-logical-perms)
!(import! &self ./metta-moses/representation/create-representation)
!(import! &self ./metta-moses/utilities/map)
!(import! &self ./metta-moses/utilities/tree)
!(import! &self ./metta-moses/utilities/pair)
!(import! &self ./metta-moses/utilities/nodeId)
!(import! &self ./metta-moses/utilities/list-methods)
!(import! &self ./metta-moses/utilities/general-helpers)
!(import! &self ./metta-moses/utilities/ordered-multimap)
!(import! &self ./metta-moses/utilities/ordered-multiset)
!(import! &self ./metta-moses/utilities/ordered-set)
!(import! &self ./metta-moses/utilities/lazy-random-selector)
!(import! &self ./metta-moses/utilities/lru-cache)
!(import! &self ./metta-moses/deme/score-deme)
!(import! &self ./metta-moses/deme/create-deme)
!(import! &self ./metta-moses/deme/deme-id-creation)
!(import! &self ./metta-moses/deme/expand-deme)
!(import! &self ./metta-moses/deme/merge-demes)

!(import! &self ./metta-moses/scoring/strategy-score-cache)
!(import! &self ./metta-moses/examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ./metta-moses/examples/tic-tac-toe/random-player-m)
!(import! &self ./metta-moses/examples/tic-tac-toe/strategy-scoring)
!(import! &self ./metta-moses/examples/tic-tac-toe/minimax-player-m)
!(import! &self ./metta-moses/examples/tic-tac-toe/game-engine)
!(import! &self ./metta-moses/examples/tic-tac-toe/moves)
!(import! &self ./metta-moses/examples/tic-tac-toe/moses-player)

!(import! &self ./metta-moses/scoring/cscore)
!(import! &self ./metta-moses/scoring/bscore)
!(import! &self ./metta-moses/scoring/fitness)
!(import! &self ./metta-moses/scoring/complexity-based-scorer)
!(import! &self ./metta-moses/scoring/cacheSpace)

!(import! &self ./metta-moses/moses/neighborhood-sampling)
!(import! &self ./metta-moses/optimization/hillclimbing/cross-top-one)
!(import! &self ./metta-moses/optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ./metta-moses/optimization/hillclimbing/hill-climbing-helpers)

!(import! &self ./metta-moses/metapopulation/exemplar-type)
!(import! &self ./metta-moses/metapopulation/exemplar-selection)
!(import! &self ./metta-moses/metapopulation/metapopulation)

!(import! &self ./metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ./metta-moses/feature-selection/feature-selection-main)
!(import! &self ./metta-moses/feature-selection/select-top-features)
!(import! &self ./metta-moses/feature-selection/similarity-scorers)
!(import! &self ./metta-moses/feature-selection/simple)
!(import! &self ./metta-moses/feature-selection/smd)
!(import! &self ./metta-moses/feature-selection/incremental)
!(import! &self ./metta-moses/feature-selection/hc)
!(import! &self ./metta-moses/feature-selection/random-feature-selection)

!(import! &self ./metta-moses/reduct/boolean-reduct/rte-helpers)
!(import! &self ./metta-moses/reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ./metta-moses/reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ./metta-moses/reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ./metta-moses/reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ./metta-moses/reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ./metta-moses/reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ./metta-moses/reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ./metta-moses/reduct/boolean-reduct/promote-common-constraints)
!(import! &self ./metta-moses/reduct/boolean-reduct/reduce-to-elegance)
; !(import! &self ./utils)

!(bind! &activeMosesStrategy (new-state .....))
!(bind! &stampState (new-state 0))

;; moved increment def here for testing
; (= (incrementState $state) (let $n (get-state $state) (let $__2 (change-state! $state (+ $n 1)) (get-state $state))))

;; Empty strategy metapop -  empty PRIORITIZED-OR with worst CScore
;; this empty strategy is used as a starting point to evolve better strategy
(= (emptyStrategyMetaPop)
   (ConsOS
     (mkExemplar
       (mkTree (mkNode PRIORITIZED-OR) Nil)  ;;  empty - no children
       (mkDemeId "0")
       (eval (worstCscore))  ;; Worst CScore
       (mkBScore (Cons -10000.0 Nil)))
     NilOS))

;; Evolve a MOSES strategy using the specified opponent and store it in activeMosesStrategy
(= (update-moses-strategy $adversary)
    (let* (
          ($nGames 5)
          ;; Map Python Game GP Adversary string to MOSES strategy policy component
          ($opponentPolicy (case $adversary
                            ((MiniMax minimax-player-m)
                             (Random random-player-m)
                            ;  (GP12X gpPlayer12-m)
                            ;  (GP6O gpPlayer6-m)
                            ;  ($_ random-player)
                             ))) ;; default and Human fallback
          ;; Target perfect win score
          ($__ (println! (opponent policy $opponentPolicy)))
          ($targetScore (mkCscore 5.0 5 1.43 0.0 3.57)) 
          ($__ (println! "After target score"))
          ;; Run Moses to find best strategy
          ($mosesResult (runMoses
                2                              ;; maxGen
                $targetScore                   ;; target
                1                              ;; maxCandOutput
                (emptyStrategyMetaPop)         ;; metaPop
                0 1                            ;; nExpansion, nDeme
                ($nGames $opponentPolicy 3.5)  ;; nGames, opponent, complexityRatio
                hillClimbing                   ;; optimizer
                30 5 2 1.0                     ;; nEval, maxCands, minPool, temp
                5 0.004 1000))                 ;; nToKeep, capCoef, genCount
          
          ;; Extract top exemplar tree
          ($__ (println! "After runMoses"))
          ($topExemplar (eval (OS.getByIdx 0 $mosesResult)))
          ($tree (eval (getExemplarTree $topExemplar)))
          ;; Clean tree (remove mkTree/mkNode wrappers native to S-expression)
          ($cleanStrategy (clean-moses-tree $tree))
          )
          ;; Bind the cleaned expression into activeMosesStrategy
          (change-state! &activeMosesStrategy $cleanStrategy)))

;; Custom tree cleaner to avoid preOrder bugs (and superposition)
(= (clean-moses-tree (mkTree (mkNode $node) Nil)) $node)
(= (clean-moses-tree (mkTree (mkNode $node) (Cons $c $cs)))
   (let $clean-children (clean-moses-children (Cons $c $cs))
     (cons-atom $node $clean-children)))

(= (clean-moses-children Nil) ())
(= (clean-moses-children (Cons $c $cs))
   (let* (($clean-c (clean-moses-tree $c))
          ($clean-cs (clean-moses-children $cs)))
     (cons-atom $clean-c $clean-cs)))

;; takes a bloated board, uses flattenBoard from utils and extracts Board (E E E E E E E E E)
;; executes the strategy using exec-strategy and retruns the initial board and final board linked by an
;; Implication link with default values of (stv 0.5 0.3) and an id for stamp value
(= (moses-player-exec $bloated-board $player)
    (let* (((Board $board) (flattenBoard $bloated-board))
          ($moses-strategy (get-state &activeMosesStrategy))
          ($move-made (moses-player $moses-strategy $board $player))
          ($_ (cut))
          ($new-board (bloatBoard (Board $move-made)))
          ($unique-stamp (incrementState &stampState)))
          
          (Sentence ((Implication (Board $board) $new-board) (stv 0.5 0.3)) ($unique-stamp))))

; !(preOrder (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)))          
; !(assertEqual
;    (let* (
;      ($result (eval (runMoses
;                 1                              ;; maxGen
;                 (mkCscore 5.0 5 1.43 0.0 3.57) ;; target
;                 3                              ;; maxCandOutput
;                 (strategyMetaPop)              ;; metaPop
;                 0 1                            ;; nExpansion, nDeme
;                 (5 random-player 3.5)            ;; nGames, opponent, ratio
;                 hillClimbing                   ;; optimizer
;                 30 5 2 1.0                     ;; nEval, maxCands, minPool, temp
;                 5 0.004 1000)))                 ;; nToKeep, capCoef, genCount
;      ($resultSize (eval (OS.length $result)))
;    )
;    (>= $resultSize 1))
;    True)

;; Test block
(= (strategyMetaPop)
   (ConsOS
     (mkExemplar
       (mkTree (mkNode PRIORITIZED-OR)
         (Cons (mkTree (mkNode playwin) Nil)
               (Cons (mkTree (mkNode playblock) Nil) Nil)))
       (mkDemeId "0")
       (mkCscore 2.0 2 0.57 0.0 1.43)
       (mkBScore (Cons 2.0 Nil)))
     NilOS))

; !(let* (($osList (runMoses
;                 2                              
;                 (mkCscore 5.0 5 1.43 0.0 3.57) 
;                 3                              
;                 (emptyStrategyMetaPop)              
;                 0 1                            
;                 (5 random-player 3.5)            
;                 hillClimbing                   
;                 30 5 2 1.0                     
;                 5 0.004 1000))
;                 ($ex (preOrder (getExemplarTree (OS.getByIdx 0 $osList))))
;                 ) 
;                 $ex)
                ; (let $exemplar (OS.getByIdx 0 $osList) (preOrder $exemplar)))


; with strategyMetaPop (ConsOS (mkExemplar (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode playwin) Nil) (Cons (mkTree (mkNode playblock) Nil) (Cons (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode playcenter) Nil) (Cons (mkTree (mkNode playwin) Nil) (Cons (mkTree (mkNode playside) Nil) Nil)))) Nil)))) (mkDemeId 1) (mkCscore 5.0 5 1.4285714285714284 0.0 3.5714285714285716) (mkBScore (Cons 1.0 (Cons 1.0 (Cons 1.0 (Cons 1.0 (Cons 1.0 Nil))))))) (ConsOS (mkExemplar (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode playwin) Nil) (Cons (mkTree (mkNode playblock) Nil) Nil))) (mkDemeId 0) (mkCscore 2.0 2 0.57 0.0 1.43) (mkBScore (Cons 2.0 Nil))) NilOS))

; with emptyStrategyMetaPop (ConsOS (mkExemplar (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode playwin) Nil) (Cons (mkTree (mkNode playside) Nil) (Cons (mkTree (mkNode playcorner) Nil) Nil)))) (Cons (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode playcenter) Nil) (Cons (mkTree (mkNode playwin) Nil) (Cons (mkTree (mkNode playside) Nil) Nil)))) Nil))) (mkDemeId 1) (mkCscore 5.0 6 1.7142857142857142 0.0 3.2857142857142856) (mkBScore (Cons 1.0 (Cons 1.0 (Cons 1.0 (Cons 1.0 (Cons 1.0 Nil))))))) (ConsOS (mkExemplar (mkTree (mkNode PRIORITIZED-OR) Nil) (mkDemeId 0) (mkCscore -10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0 0.0 0.0 -10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000) (mkBScore (Cons -1.0e+04 Nil))) NilOS))

; !(update-moses-strategy "Random")
; !(get-state &activeMosesStrategy) ;; (PRIORITIZED-OR (PRIORITIZED-OR playwin playside playcorner) (PRIORITIZED-OR playcenter playwin playside))

; ; !(update-moses-strategy "MiniMax")
; ; !(get-state &activeMosesStrategy) ;; (PRIORITIZED-OR (PRIORITIZED-OR playcenter playwin playblock) (PRIORITIZED-OR playcenter playside playcorner))

; !(let $board (bloatBoard (Board (E E E E E E E E E))) (moses-player-exec $board X))