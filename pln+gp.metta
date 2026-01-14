!(import! &self ./PLN/pln)
!(import! &self "run_evolution.py")
!(import! &self utils)

!(bind! &perception (new-space))
!(bind! &newPerceptions (new-space))
!(bind! &belief (new-space))
!(bind! &newBeliefs (new-space))
!(bind! &stateSpace (new-space))
!(bind! &count (new-state 0))

(= (STV $fact)
          (let*
            (
              ($m (if (= $fact ($link $a $b))
                      (foldall + (match &perception $fact 1) 0)
                      (foldall + (match &perception ($link $a $fact) 1) 0))) ;; Positive count
              ($N (match &stateSpace (GameCount $x) $x)) ;; Total count
              ($s (py-call (round (/safe $m $N) 4)))
              ;; ($_ (println! (M: $m fact: $fact)))
            )
            (stv (if (> $s 1) 1 $s) (py-call (round (/ $N (+ $N (K))) 4))))
          )

(= (increment $state) (let $n (get-state $state) (let $_ (change-state! $state (+ $n 1)) (get-state $state))))
(= (update-atom $space $old $new) (match $space $old (let $_ (remove-atom $space $old) (add-atom $space $new))))

(= (populate-belief $atoms)
   (let*
      (
        ($uniqueAtoms (unique-atom $atoms))
        ($updatedPerceptTruthPair (collapse (let $percept (superpose $uniqueAtoms) ($percept (STV $percept)))))
        ;; ($_ (println! (UpdatedPercept: $updatedPerceptTruthPair)))
        ($oldBeliefs (collapse (let ($percept $stvN) (superpose $updatedPerceptTruthPair) (match &belief (Sentence ($percept $stv) $Ev) (Sentence ($percept $stv) $Ev)))))
        ($revisedPercepts (collapse (let*
               (
                 (($percept $stvN) (superpose $updatedPerceptTruthPair))
                 ((Sentence ($percept $stv) $Ev) (superpose $oldBeliefs))
                 ((Sentence ($percept $stvU) $Ev) (BestCandidate PriorityRank () (collapse (|- ($percept $stv) ($percept $stvN)))))
                 ($_ (update-atom &belief (Sentence ($percept $stv) $Ev) (Sentence ($percept $stvU) $Ev)))
               )
               $percept)))
        ($uniqueRevisedPercepts (unique-atom $revisedPercepts))
        ($updatedPercepts (collapse (let ($percept $stv) (superpose $updatedPerceptTruthPair) $percept)))
        ($revisedBeliefs (collapse (let $percept (superpose $uniqueRevisedPercepts) (match &belief (Sentence ($percept $stv) $Ev) (Sentence ($percept $stv) $Ev)))))
        ($newPercepts (subtraction-atom $updatedPercepts $uniqueRevisedPercepts))
        ($newBeliefs (collapse (let*
                                 (
                                   ($percept (superpose $newPercepts))
                                   (($percept $stvN) (superpose $updatedPerceptTruthPair))
                                   ($i (increment &count))
                                 )
                                 (Sentence ($percept $stvN) ($i)))))
        ($injectedBeliefs (collapse (get-atoms &newBeliefs)))
        ($_ (collapse (let*
                         (
                           ;; ($_ (println! (NewBeliefs: $newBeliefs)))
                           ($belief (superpose $newBeliefs))
                           ;; ($_ (println! (Added Belief: $belief)))
                         )
                         (add-atom &belief $belief))))

        ($previousBeliefs (union-atom $injectedBeliefs $revisedBeliefs))
        ($totalBeliefs (union-atom $previousBeliefs $newBeliefs))
        ;; ($_ (println! (NewPercepts: $newPercepts)))
        ;; ($_ (println! (RevisedPercepts:  $uniqueRevisedPercepts)))
        ;; ($_ (println! (NewBeliefs': (collapse (get-atoms &belief)))))
        ;; ($_ (println! (NewBeliefs: $newBeliefs)))
        ($_ (println! (OldBeliefs: $oldBeliefs)))
        ($_ (println! (TotalBeleifs: $totalBeliefs)))
      )
      ($totalBeliefs $oldBeliefs))
)

(= (getNextMove $currentState (Sentence (($link $initialState $finalState) $stv) $plan))
   (let*
     (
       ;; ($_ (println! (Plan: $plan)))
       ($moveId (superpose $plan))
       ;; ($_ (println! (MoveId: $moveId)))
       ($interState (match &belief (Sentence (($links $currentState $interState) $stvs) ($moveId)) $interState))
       ;; ($_ (println! (InterState: $interState)))
     )
     $interState))


(= (runGp $board $player)
   (let*
     (
       ;; ($_ (println! (Inside runGp)))
       ($flatBoard (flattenBoard $board))
       ($_ (py-call (run_evolution.run_moses $flatBoard $player 2 2)))
       ($_ (import! &self policies))
       ($_ (py-call (run_evolution.clean_file "policies.metta")))
       ($atoms (collapse (match &self (Sentence (($link $flatBoard $nextBoard) $stv) $id) 
                            (let $_ (remove-atom &self (Sentence (($link $flatBoard $nextBoard) $stv) $id)) (Sentence (($link $flatBoard (bloatBoard $nextBoard)) $stv) $id)))))
     )
     $atoms))

;; Write the main loop using PLN and GP.
;;
;; Takes an initial game state and starts the loop.
;; Searches the current belief and perception to find the next best move.
;; If PLN fails to find the next best move call the GP with 2 as it's maximum depth.
;; Load from the file into a belief space.
;; Rerun the PLN now on the newly introduced game moves.
;; Repeat the above two steps until PLN finds the best solution
(= (move $board $player)
   (let*
        (
          ;; ($_ (println! (Before pln)))
          ($winningState (atom_concat Game_Win_ $player))
          ($winningPlan (PLN.Query (collapse (get-atoms &belief)) (Inheritance $board $winningState) 200 100 200))
          ($nextMove (if (!= $winningPlan ())
                         (getNextMove $board $winningPlan)
                         (let $commonMovePlan (PLN.Query (collapse (get-atoms &belief)) (Implication $board (Board $row $rows)) 300 500 300)
                              (if (!= $commonMovePlan ())
                                  (let (Sentence ((Implication $board $nextMove) $stv) $id) $commonMovePlan $nextMove)
                                  ()))))
          ;; ($_ (println! (NextMove: $nextMove)))
          ($gpMove (if (== $nextMove ())
                       (let $atoms (runGp $board $player) (BestCandidate ThompsonRank () $atoms))
                       $nextMove))
          ((Sentence (($link $currentBoard $nextBoard) $stv) $id) $gpMove)

          ($_ (println! (if (!= $nextMove ()) (Pln Found move $nextMove) (GP Found move $gpMove))))
          ;; ($_ (println! (GpMove: $gpMove)))
          ;; ($_ (println! (NextBoard: $nextBoard)))
          ($_ (add-atom &perception (Implication $board $nextBoard)))
          ($_ (add-atom &newPerceptions (Implication $board $nextBoard)))
          ($_ (add-atom &perception $nextBoard))
          ($_ (add-atom &newPerceptions $nextBoard))
        )
        $nextBoard))

;; !(move (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E)))) X)

(= (gameOver $board)
   (let $winner (py-call (run_evolution.check_winner $board))
                (or (== X $winner) (== O $winner))))

(= (boardFull $board)
   (let $full (py-call (run_evolution.is_full $board))
                (== $full 1)))

(= (drawBoard $currentState) (let $board (py-call (run_evolution.to_string $currentState)) (println! $board)))

(= (takeInput $currentState)
   (let*
      (
        ($_ (println! (Make your move: <e.g> 0 - 8)))
        ($input (readln!))
        ($validMove (py-call (run_evolution.is_valid $currentState $input)))
      )
      (if (== $validMove $input) ;; valid
          $input
          (let $x (println! (Move: $input is invalid)) (takeInput $currentState)))))

(= (flipPlayer $player) (if (== $player X) O X))

(= (savePerceptions)
   (let $newPercepts (collapse (get-atoms &newPerceptions)) (saveExpressions "WM/perception.metta" $newPercepts)))

(= (saveBeliefs ($newBeliefs $oldBeliefs))
   (let*
     (
       ;; ($_ (println! (Inside SaveBelief)))
       ;; ($_ (println! (NewBeliefs: $newBeliefs)))
       ($ro (py-call (utils.remove_from_file "WM/belief.metta" $oldBeliefs)))
       ($rn (saveExpressions "WM/belief.metta" $newBeliefs))
     )
     true))

(= (saveCounts ($lastCount $gameCount))
   (let*
      (

          ($r (py-call (utils.remove_from_file "WM/state.metta" ((Count $lastCount) (GameCount $gameCount)))))
          ($content (let $strs (collapse (superpose (
                                                (py-call (utils.to_metta_str (Count (get-state &count))))
                                                (py-call (utils.to_metta_str (GameCount (+ 1 $gameCount))))))) (py-call (utils.join_metta_strs $strs))))
          ;; ($_ (println! (CountContent: $content)))
          ($ra (py-call (utils.add_to_file "WM/state.metta" $content)))
      )
       true))

;; Load belief and perceptions from file into space
;; Start the game play:
;;    If player X, make the first move.
;;    If player O, wait for the opponent to make a move then make your own move.
;;    Add moves into the perception space
;;    Repeat the above moves until the game is over
;;    When the game is over update beliefs
;;    Save belief and perceptions into the space.

(= (initGameState $player)
   (let*
        (
          ($initState (py-call (run_evolution.Board (Board (E E E E E E E E E)))))
          ($_ (import! &perception ./WM/perception))
          ($_ (import! &belief ./WM/belief))
          ($_ (import! &stateSpace ./WM/state))
          (($lastCount) (collapse (match &stateSpace (Count $x) $x)))
          ($__ (change-state! &count $lastCount))
          ($_ (if (== $player X) true (drawBoard $initState)))

          ($pa (add-atom &perception (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))))
          ($npa (add-atom &newPerceptions (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))))

          ($_ (gameLoop $initState $player (== $player X)))
          (($gameCount) (collapse (match &stateSpace (GameCount $x) $x)))

          ;; ($_ (println! ""))
          ;; ($_ (println! "BeforeBeliefUpdate:"))
          ;; ($nothing (collapse (println! (get-atoms &belief))))
          ;; ($_ (println! ""))

          ;; Save the perception to file
          ($rp (savePerceptions))

          ;; Save the beliefs to file
          ($beliefs (populate-belief (collapse (get-atoms &perception))))

          ;; ($_ (println! ""))
          ;; ($_ (println! "AfterBeliefUpdate:"))
          ;; ($nothing (collapse (println! (get-atoms &belief))))
          ;; ($_ (println! ""))

          ($rb (saveBeliefs $beliefs))
          ($rc (saveCounts ($lastCount $gameCount)))
        )
        true))


(= (gameLoop $currentState $player $myTurn)
   (if (boardFull $currentState)
       (let*
          (
            ($nextCount (increment &count))
            ($mettaBoard (bloatBoard (load_board_metta $currentState)))
            ($exists (!= (collapse (match &belief
                                          (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) $Ev)
                                          (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) $Ev))) ()))

            ($_ (add-atom &newPerceptions $mettaBoard))
            ($_ (if $exists
                    true
                    (add-atom &newBeliefs (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) ($nextCount))))))
          (println! (Game ended in draw)))
   (if (gameOver $currentState)
       (let*
          (
            ($winner (py-call (run_evolution.check_winner $currentState)))
            ($winningState (atom_concat Game_Win_ $winner))
            ($_ (println! (GameOver! Winner is: $winner)))
            ($mettaBoard (bloatBoard (load_board_metta $currentState)))
            ($nextCount (increment &count))
            ($exists (!= (collapse (match &belief
                                          (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) $Ev)
                                          (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) $Ev))) ()))

            ;; ($_ (println! (Adding (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) ($nextCount)) into Belief)))

            ($_ (if $exists
                    true
                    (add-atom &newBeliefs (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) ($nextCount)))))
          )
          true
       )
       (let*
          (
            ;; ($_ (println! (Inside game loop myTurn: $myTurn)))
            ($opponent (flipPlayer $player))
            ($mettaBoard (bloatBoard (load_board_metta $currentState)))
            ($nextBoard (if $myTurn
                            (let $nextMettaBoard (move $mettaBoard $player) (load_board_python (flattenBoard $nextMettaBoard)))
                            (let*
                               (
                                 ($move (takeInput $currentState))
                                 ($nextState (py-call (run_evolution.make_move $currentState $move $opponent)))
                                 ($nextMettaboard (bloatBoard (load_board_metta $nextState)))
                                 ($_ (add-atom &perception $nextMettaboard))
                                 ($_ (add-atom &newPerceptions $nextMettaboard))

                                 ($_ (add-atom &perception (Implication $mettaBoard $nextMettaboard)))
                                 ($_ (add-atom &newPerceptions (Implication $mettaBoard $nextMettaboard)))
                               )
                               $nextState)))
            ($nextMettaBoard (bloatBoard (load_board_metta $nextBoard)))
            ($_ (drawBoard $nextBoard))
          )
          (gameLoop $nextBoard $player (not $myTurn))))))

!(initGameState X)
