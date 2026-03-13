!(import! &self ./Adversaries/helpers)
!(import! &self ./Adversaries/minimax-player)
!(import! &self utils)

!(import! &self ./Adversaries/random-player)

!(import! &self "gp12_x_player.py")
!(import! &self "gp6_o_player.py")

!(import! &self ./Adversaries/gp-12-x-player)
!(import! &self ./Adversaries/gp-6-o-player)

!(import! &self pln+gp)

; !(import! &self ./metta-moses/representation/lsk)
; !(import! &self ./metta-moses/representation/instance)
; !(import! &self ./metta-moses/representation/build-knobs)
; !(import! &self ./metta-moses/representation/knob-mapper)
; !(import! &self ./metta-moses/representation/logical-probe)
; !(import! &self ./metta-moses/representation/build-logical)
; !(import! &self ./metta-moses/representation/representation)
; !(import! &self ./metta-moses/representation/add-logical-knobs)
; !(import! &self ./metta-moses/representation/knob-representation)
; !(import! &self ./metta-moses/representation/sample-logical-perms)
; !(import! &self ./metta-moses/representation/create-representation)
; !(import! &self ./metta-moses/utilities/map)
; !(import! &self ./metta-moses/utilities/tree)
; !(import! &self ./metta-moses/utilities/pair)
; !(import! &self ./metta-moses/utilities/nodeId)
; !(import! &self ./metta-moses/utilities/list-methods)
; !(import! &self ./metta-moses/utilities/general-helpers)
; !(import! &self ./metta-moses/utilities/ordered-multimap)
; !(import! &self ./metta-moses/utilities/ordered-multiset)
; !(import! &self ./metta-moses/utilities/ordered-set)
; !(import! &self ./metta-moses/utilities/lazy-random-selector)
; !(import! &self ./metta-moses/utilities/lru-cache)
; !(import! &self ./metta-moses/deme/score-deme)
; !(import! &self ./metta-moses/deme/create-deme)
; !(import! &self ./metta-moses/deme/deme-id-creation)
; !(import! &self ./metta-moses/deme/expand-deme)
; !(import! &self ./metta-moses/deme/merge-demes)

; !(import! &self ./metta-moses/scoring/strategy-score-cache)
; !(import! &self ./metta-moses/examples/tic-tac-toe/tic-tac-toe-helpers)
; !(import! &self ./metta-moses/examples/tic-tac-toe/random-player)
; !(import! &self ./metta-moses/examples/tic-tac-toe/strategy-scoring)
; !(import! &self ./metta-moses/examples/tic-tac-toe/minimax-player)
; !(import! &self ./metta-moses/examples/tic-tac-toe/game-engine)
; !(import! &self ./metta-moses/examples/tic-tac-toe/moves)
; !(import! &self ./metta-moses/examples/tic-tac-toe/moses-player)

; !(import! &self ./metta-moses/scoring/cscore)
; !(import! &self ./metta-moses/scoring/bscore)
; !(import! &self ./metta-moses/scoring/fitness)
; !(import! &self ./metta-moses/scoring/complexity-based-scorer)
; !(import! &self ./metta-moses/scoring/cacheSpace)

; !(import! &self ./metta-moses/moses/neighborhood-sampling)
; !(import! &self ./metta-moses/optimization/hillclimbing/cross-top-one)
; !(import! &self ./metta-moses/optimization/hillclimbing/cross-top-one-helpers)
; !(import! &self ./metta-moses/optimization/hillclimbing/hill-climbing-helpers)

; !(import! &self ./metta-moses/metapopulation/exemplar-type)
; !(import! &self ./metta-moses/metapopulation/exemplar-selection)
; !(import! &self ./metta-moses/metapopulation/metapopulation)

; !(import! &self ./metta-moses/feature-selection/feature-selection-helpers)
; !(import! &self ./metta-moses/feature-selection/feature-selection-main)
; !(import! &self ./metta-moses/feature-selection/select-top-features)
; !(import! &self ./metta-moses/feature-selection/similarity-scorers)
; !(import! &self ./metta-moses/feature-selection/simple)
; !(import! &self ./metta-moses/feature-selection/smd)
; !(import! &self ./metta-moses/feature-selection/incremental)
; !(import! &self ./metta-moses/feature-selection/hc)
; !(import! &self ./metta-moses/feature-selection/random-feature-selection)

; !(import! &self ./metta-moses/reduct/boolean-reduct/rte-helpers)
; !(import! &self ./metta-moses/reduct/boolean-reduct/cut-unnecessary-or)
; !(import! &self ./metta-moses/reduct/boolean-reduct/cut-unnecessary-and)
; !(import! &self ./metta-moses/reduct/boolean-reduct/n-ary-propagate-not)
; !(import! &self ./metta-moses/reduct/boolean-reduct/n-ary-gather-junctors)
; !(import! &self ./metta-moses/reduct/boolean-reduct/delete-inconsistent-handle)
; !(import! &self ./metta-moses/reduct/boolean-reduct/zero-constraint-subsumption)
; !(import! &self ./metta-moses/reduct/boolean-reduct/one-constraint-subsumption)
; !(import! &self ./metta-moses/reduct/boolean-reduct/promote-common-constraints)
; !(import! &self ./metta-moses/reduct/boolean-reduct/reduce-to-elegance)

!(import! &self moses_bridge)

!(bind! &totalGames (new-state 0))
!(bind! &totalLoss (new-state 0))
!(bind! &totalWins (new-state 0))

!(bind! &activeMosesStrategy (new-state ...))
!(bind! &stampState (new-state 1))

(= (resetCounts)
   (let*
      (

          ;; ($_ (py-call (run_evolution.clean_file "WM/state.metta")))
          ;; ($content (let $strs (collapse (superpose (
          ;;                                       (py-call (utils.to_metta_str (Count 1)))
          ;;                                       (py-call (utils.to_metta_str (GameCount 1)))))) (py-call (utils.join_metta_strs $strs))))
          ;; ($ra (py-call (utils.add_to_file "WM/state.metta" $content)))
          ($_ (change-state! &totalGames 0))
          ($_ (change-state! &totalLoss 0))
          ($_ (change-state! &totalWins 0))

          ($_ (change-state! &plnWinMoves 0))
          ($_ (change-state! &plnCommonMoves 0))
          ($_ (change-state! &totalMoves 0))
      )
       true))

;; N is number of times the game will be played where opponent 
;;  is whether the adversery is a human or another policy which
;;  determines where the input comes from.
(= (testLearning $n $adversary)
   (let*
      (
        ;; ;; Start from empty perception and belief to make the test fair. But back up is kept to restore it back.
        ;; ($_ (py-call (run_evolution.clean_file "WM/perception.metta")))
        ;; ($_ (py-call (run_evolution.clean_file "WM/belief.metta")))
        ;; ($_ (py-call (run_evolution.backup_file "WM/state.metta")))
        ($_ (resetCounts))

        ($_ (runTest $n X $adversary))

        ;; Collected states
        ($totalGame (get-state &totalGames))
        ($totalLoss (get-state &totalLoss))
        ($totalWins (get-state &totalWins))

        ($plnWinMoves (get-state &plnWinMoves))
        ($plnCommonMoves (get-state &plnCommonMoves))
        ($totalMoves (get-state &totalMoves))

        ($goodPlayRate (* (/ (- $totalGame $totalLoss) $totalGame) 100))
        ($winRate (* (/ $totalWins $totalGame) 100))
        ($plnMovePercent (* (/ (+ $plnWinMoves $plnCommonMoves) $totalMoves) 100) )
        ($plnWinMovesPercent (if (> $plnMovePercent 0) (* (/ $plnWinMoves (+ $plnWinMoves $plnCommonMoves)) 100) 0))

        ($_ (println! ""))
        ($_ (println! (===================================================)))
        ($_ (println! (GamePlayed against: $adversary)))
        ($_ (println! (TotalGamesPlayed: $totalGame NumberOfWins: $totalWins NumberOfLosses: $totalLoss NumberOfDraw: (- $totalGame (+ $totalLoss $totalWins)))))
        ($_ (println! (NumberOfMovesMade: $totalMoves)))
        ($_ (println! (PLNMoves: (+ $plnWinMoves $plnCommonMoves) WinMoves: $plnWinMoves CommonMoves: $plnCommonMoves)))
        ($_ (println! ""))
        ($_ (println! (The algorithm did not lose $goodPlayRate percent of the time)))
        ($_ (println! (The algorithm won $winRate percent of the time)))
        ($_ (println! ($plnMovePercent percent of the moves made were generated by pln)))
        ($_ (println! ($plnWinMovesPercent percent of the moves made by pln were winning move plans)))
        ($_ (println! (===================================================)))
        ($_ (println! ""))

        ;; ($_ (py-call (run_evolution.restore_file "WM/perception.metta")))
        ;; ($_ (py-call (run_evolution.restore_file "WM/belief.metta")))
        ;; ($_ (py-call (run_evolution.restore_file "WM/state.metta")))
      )
      true))

(= (runTest $n $player $adversary)
   (if (<= $n 0)
       True ;; Inidicating the test run to compeletion
       (let*
         (
           ($_ (println! "") )
           ($opponent (flipPlayer $player))
           ($_ (println! (Running Game $n => Pln: $player $adversary : $opponent ...) ) )
           ((GameWinner $winner) (initGameState $player $adversary))
           ($_ (if (!= $winner NoOne) (println! (Winner: (if (== $opponent $winner) Adversary PLN+GP))) true))

           ($tgr (increment &totalGames))
           ($ttl (if (== $winner $opponent)
                     (increment &totalLoss)
                     (if (== $winner $player)
                         (increment &totalWins)
                         ())))
         )
         (runTest (- $n 1) $opponent $adversary))))

;; Training
; !(testLearning 5 Random) ;; Should be 3
; !(testLearning 7 GP6O) ;; Should be 5
; !(testLearning 10 GP12X) ;; Should be 7
; !(testLearning 15 MiniMax) ;; Should stay the same

; ;; Test
; !(testLearning 5 MiniMax)

;; !(initGameState X Human)
;; !(testLearning 5 Random)
;; !(testLearning 5 MiniMax)
;; !(testLearning 5 GP6O)
;; !(testLearning 5 MiniMax)
;; !(testLearning 5 GP12X)
;; !(testLearning 15 MiniMax)

!(update-moses-strategy "Random")

!(let $board (bloatBoard (Board (E E E E E E E E E)))
         (moses-player-exec $board X))
