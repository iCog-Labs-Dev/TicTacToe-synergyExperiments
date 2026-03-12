!(import! &self ./PLN/pln)
!(import! &self "run_evolution.py")

!(import! &self ./PLN/BC/thompson-select)
!(import! &self ./PLN/BC/directed-modus-ponens)

!(bind! &perception (new-space))
!(bind! &newPerceptions (new-space))
!(bind! &belief (new-space))
!(bind! &newBeliefs (new-space))
!(bind! &stateSpace (new-space))

!(bind! &count (new-state 0))
!(bind! &plnWinMoves (new-state 0))
!(bind! &plnCommonMoves (new-state 0))
!(bind! &totalMoves (new-state 0))

(= (STV $fact)
          (let*
            (
              ($m (if (= $fact ($link $a $b))
                      (foldall + (match &perception $fact 1) 0)
                      (foldall + (match &perception ($link $a $fact) 1) 0))) ;; Positive count
              ($N (match &stateSpace (GameCount $x) $x)) ;; Total count
              ($s (py-call (round (/safe $m $N) 4)))
              ;; ($__1 (println! (M: $m fact: $fact)))
            )
            (stv (if (> $s 1) 1 $s) (py-call (round (/ $N (+ $N (K))) 4))))
          )

(= (increment $state) (let $n (get-state $state) (let $__2 (change-state! $state (+ $n 1)) (get-state $state))))
(= (update-atom $space $old $new) (match $space $old (let $__3 (remove-atom $space $old) (add-atom $space $new))))

(= (populate-belief $atoms)
   (let*
      (
        ($uniqueAtoms (unique-atom $atoms))
        ($updatedPerceptTruthPair (collapse (let $percept (superpose $uniqueAtoms) ($percept (STV $percept)))))
        ;; ($__4 (println! (UpdatedPercept: $updatedPerceptTruthPair)))
        ($oldBeliefs (collapse (let ($percept $stvN) (superpose $updatedPerceptTruthPair) (match &belief (Sentence ($percept $stv) $Ev) (Sentence ($percept $stv) $Ev)))))
        ($revisedPercepts (collapse (let*
               (
                 (($percept $stvN) (superpose $updatedPerceptTruthPair))
                 ((Sentence ($percept $stv) $Ev) (superpose $oldBeliefs))
                 ((Sentence ($percept $stvU) $Ev) (BestCandidate PriorityRank () (collapse (|- ($percept $stv) ($percept $stvN)))))
                 ($__5 (update-atom &belief (Sentence ($percept $stv) $Ev) (Sentence ($percept $stvU) $Ev)))
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
        ($__6 (collapse (let*
                         (
                           ;; ($__7 (println! (NewBeliefs: $newBeliefs)))
                           ($belief (superpose $newBeliefs))
                           ;; ($__8 (println! (Added Belief: $belief)))
                         )
                         (add-atom &belief $belief))))

        ($previousBeliefs (union-atom $injectedBeliefs $revisedBeliefs))
        ($totalBeliefs (union-atom $previousBeliefs $newBeliefs))
        ;; ($__9 (println! (NewPercepts: $newPercepts)))
        ;; ($__10 (println! (RevisedPercepts:  $uniqueRevisedPercepts)))
        ;; ($__11 (println! (NewBeliefs': (collapse (get-atoms &belief)))))
        ;; ($__12 (println! (NewBeliefs: $newBeliefs)))
        ;; ($__13 (println! (OldBeliefs: $oldBeliefs)))
        ;; ($__14 (println! (TotalBeleifs: $totalBeliefs)))
      )
      ($totalBeliefs $oldBeliefs))
)

(= (getNextMove $currentState (Sentence (($link $initialState $finalState) $stv) $plan))
   (let*
     (
       ;; ($__15 (println! (Plan: $plan)))
       ($moveId (superpose $plan))
      ;  ($__16 (println! (MoveId: $moveId)))
       ($movePair (match &belief (Sentence (($links $currentState $interState) $stvs) ($moveId)) (Sentence (($links $currentState $interState) $stvs) ($moveId))))
       ;; ($__17 (println! (InterState: $interState)))
     )
     $movePair))


(= (runGp $board $player)
   (let*
     (
       ;; ($__18 (println! (Inside runGp)))
       ($flatBoard (flattenBoard $board))
       ($__19 (py-call (run_evolution.run_moses $flatBoard $player 2 2)))
       ($__20 (import! &self policies))
       ($__21 (py-call (run_evolution.clean_file "policies.metta")))
       ($atoms (collapse (match &self (Sentence (($link $flatBoard $nextBoard) $stv) $id) 
                            (let $__22 (remove-atom &self (Sentence (($link $flatBoard $nextBoard) $stv) $id)) (Sentence (($link $flatBoard (bloatBoard $nextBoard)) $stv) $id)))))
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
          ;; ($__23 (println! (Before pln)))
          ($winningState (GameWin $player)) ;; TODO: Also handle draw states
          ; ($winningPlan (PLN.Query (collapse (get-atoms &belief)) (Inheritance $board $winningState) 800 300 800))
          ($__24 (println! "Here"))
          ($__25 (println! (board $board)))
          ($winningPlan (BC.drive &belief $winningState $board (S (S (S (S (S (S (S (S Z))))))))))
          ($__26 (println! (winning plansdsAD: $winningPlan)))
          ($nextMove (if (!= $winningPlan ())
                         (let $__27 (println! (WinningPlan Found: $winningPlan))
                              (let $wpr (increment &plnWinMoves) (getNextMove $board $winningPlan)))
                        ;  (let $drawPlan (PLN.Query (collapse (get-atoms &belief)) (Inheritance $board Draw) 800 300 800)
                         (let $drawPlan (BC.drive &belief Draw $board (S (S (S (S (S (S (S (S Z)))))))))
                              (if (!= $drawPlan ())
                                  (let $__28 (println! (DrawPlan Found: $drawPlan))
                                      (let $dpr (increment &plnWinMoves) (getNextMove $board $drawPlan)))
                                  ; (let $commonPlan (PLN.Query (collapse (get-atoms &belief)) (Implication $board (Board $row $rows)) 20 10 20)
                                  (let $commonPlan (BC.drive &belief (Board $row $rows) $board (S (S (S (S (S (S (S (S Z)))))))))
                                      (if (!= $commonPlan ())
                                          (let $cpr (increment &plnCommonMoves) (getNextMove $board $commonPlan))
                                          ()))))))
                                        
          ($__29 (println! (NextMove: $nextMove)))
          ($gpMove (if (== $nextMove ())
                       (let $atoms (runGp $board $player) (BestCandidate ThompsonRank () $atoms))
                       $nextMove))
          ($__30 (println! (gp move $gpMove)))
          ((Sentence (($link $currentBoard $nextBoard) $stv) $id) $gpMove)
          ($tmr (increment &totalMoves))

          ;; ($__31 (println! (if (!= $nextMove ()) (Pln Found move $nextMove) (GP Found move $gpMove))))
          ;; ($__32 (println! (GpMove: $gpMove)))
          ;; ($__33 (println! (NextBoard: $nextBoard)))
          ($__34 (add-atom &perception (Implication $board $nextBoard)))
          ($__35 (add-atom &newPerceptions (Implication $board $nextBoard)))
          ($__36 (add-atom &perception $nextBoard))
          ($__37 (add-atom &newPerceptions $nextBoard))
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

(= (takeInput $adversary $opponent $currentState)
   (case $adversary
          (
            (Human (let*
                      (
                        ($__38 (println! (Make your move: <e.g> 0 - 8)))
                        ($input (readln!))
                        ($validMove (py-call (run_evolution.is_valid $currentState $input)))
                      )
                      (if (== $validMove $input) ;; valid
                          $input
                          (let $x (println! (Move: $input is invalid)) (takeInput $adversary $opponent $currentState)))))

            (MiniMax (let*
                        (
                          ((Board $miniMaxBoard) (load_board_metta $currentState))
                          (($idx $nextBoard) (minimax-player $miniMaxBoard $opponent)))
                        $idx))
            (Random (let*
                        (
                          ((Board $randomBoard) (load_board_metta $currentState))
                          (($idx $nextBoard) (random-player $randomBoard $opponent)))
                        $idx))
            (GP12X (let*
                                    (
                                      ((Board $gp12Board) (load_board_metta $currentState))
                                      (($idx $nextBoard) (gpPlayer12 $gp12Board $opponent)))
                                    $idx))

            (GP6O (let*
                                    (
                                      ((Board $gp6Board) (load_board_metta $currentState))
                                      (($idx $nextBoard) (gpPlayer6 $gp6Board $opponent)))
                                    $idx))
            ))
)

(= (flipPlayer $player) (if (== $player X) O X))

(= (savePerceptions)
   (let $newPercepts (collapse (get-atoms &newPerceptions)) (saveExpressions "WM/perception.metta" $newPercepts)))

(= (saveBeliefs ($newBeliefs $oldBeliefs))
   (let*
     (
       ;; ($__39 (println! (Inside SaveBelief)))
       ;; ($__40 (println! (NewBeliefs: $newBeliefs)))
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
          ;; ($__41 (println! (CountContent: $content)))
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

;; The adversary tells us where adversary's input comes from. E.g. terminal input for human.
;; Adversary can be: Human, MiniMax
(= (initGameState $player $adversary)
   (let*
        (
          ($initState (py-call (run_evolution.Board (Board (E E E E E E E E E)))))
          ($__42 (import! &perception ./WM/perception))
          ($__43 (import! &belief ./WM/permanent-belief))
          ($__44 (import! &belief ./WM/belief))
          ($__45 (import! &stateSpace ./WM/state))
          (($lastCount) (collapse (match &stateSpace (Count $x) $x)))
          ($__ (change-state! &count $lastCount))
          ($__46 (if (== $player X) true (drawBoard $initState)))

          ($pa (add-atom &perception (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))))
          ($npa (add-atom &newPerceptions (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))))

          ($winningState (gameLoop $adversary $initState $player (== $player X)))
          (($gameCount) (collapse (match &stateSpace (GameCount $x) $x)))

          ;; ($__47 (println! ""))
          ;; ($__48 (println! "BeforeBeliefUpdate:"))
          ;; ($nothing (collapse (println! (get-atoms &belief))))
          ;; ($__49 (println! ""))

          ;; Save the perception to file
          ($rp (savePerceptions))

          ;; Save the beliefs to file
          ($beliefs (populate-belief (collapse (get-atoms &perception))))

          ;; ($__50 (println! ""))
          ;; ($__51 (println! "AfterBeliefUpdate:"))
          ;; ($nothing (collapse (println! (get-atoms &belief))))
          ;; ($__52 (println! ""))

          ($rb (saveBeliefs $beliefs))
          ($rc (saveCounts ($lastCount $gameCount)))
          ($csrs (collapse (clearSpace (superpose (&perception &newPerceptions &belief &newBeliefs &stateSpace))))) ;; Cleaning up the space for next execution ;; FIX: Preferably we want to keep this and terminate only when the game play is stopped.
        )
        $winningState))



(= (gameLoop $adversary $currentState $player $myTurn)
   (if (gameOver $currentState)
       (let*
          (
            ($winner (py-call (run_evolution.check_winner $currentState)))
            ($winningState (GameWin $winner))
            ($__53 (println! (GameOver! Winner is: $winner)))
            ($mettaBoard (bloatBoard (load_board_metta $currentState)))
            ($nextCount (increment &count))
            ($exists (!= (collapse (match &belief
                                          (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) $Ev)
                                          (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) $Ev))) ()))

            ;; ($__54 (println! (Adding (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) ($nextCount)) into Belief)))

            ($__55 (if $exists
                    true
                    (add-atom &newBeliefs (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) ($nextCount)))))
          )
          (GameWinner $winner)
       )
   (if (boardFull $currentState)
       (let*
          (
            ($nextCount (increment &count))
            ($mettaBoard (bloatBoard (load_board_metta $currentState)))
            ($exists (!= (collapse (match &belief
                                          (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9)) $Ev)
                                          (Sentence ((Inheritance $mettaBoard $winningState) (stv 0.9 0.9)) $Ev))) ()))

            ($__56 (add-atom &newPerceptions $mettaBoard))
            ($__57 (if $exists
                    true
                    (add-atom &newBeliefs (Sentence ((Inheritance $mettaBoard Draw) (stv 0.9 0.9)) ($nextCount)))))
            ($__58 (println! (Game ended in draw))))
          (GameWinner NoOne))
       (let*
          (
            ;; ($__59 (println! (Inside game loop myTurn: $myTurn)))
            ($opponent (flipPlayer $player))
            ($mettaBoard (bloatBoard (load_board_metta $currentState)))
            ($nextBoard (if $myTurn
                            (let $nextMettaBoard (move $mettaBoard $player) (load_board_python (flattenBoard $nextMettaBoard)))
                            (let*
                               (
                                 ($nextMettaboard (let*
                                                      (
                                                        ($move (takeInput $adversary $opponent $currentState))
                                                        ($nextState (py-call (run_evolution.make_move $currentState $move $opponent))))
                                                      (bloatBoard (load_board_metta $nextState))))

                                 ($__60 (add-atom &perception $nextMettaboard))
                                 ($__61 (add-atom &newPerceptions $nextMettaboard))

                                 ($__62 (add-atom &perception (Implication $mettaBoard $nextMettaboard)))
                                 ($__63 (add-atom &newPerceptions (Implication $mettaBoard $nextMettaboard)))
                               )
                               $nextState)))
            ($nextMettaBoard (bloatBoard (load_board_metta $nextBoard)))
            ($__64 (drawBoard $nextBoard))
          )
          (gameLoop $adversary $nextBoard $player (not $myTurn))))))

