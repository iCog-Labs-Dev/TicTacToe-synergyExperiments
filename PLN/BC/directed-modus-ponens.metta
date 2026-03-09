
;; ============================================================
;; Revision -- if neeeded -- for now I am using thompson select
;; ============================================================
(= (revision $sentences)
    (if (== $sentences ()) 
        ()
        (let* ((((Sentence ($goal $stv1st) $ev1st) $rest) (decons-atom $sentences))
                (((stv $combined-c $combined-s) $evidences) 
                    (foldl-atom $rest ($stv1st $ev1st) ($init-stv $ev-acc) 
                        (Sentence ($g $stv) $ev) (if (StampDisjoint $ev-acc $ev)
                                                     ((Truth_Revision $init-stv $stv) (StampConcat $ev-acc $ev))
                                                     ($stv1st $ev1st)))))
                (Sentence ($goal (stv $combined-c $combined-s)) $evidences))))     

;; I perfer using a thompson sampling approach to select one possible path from the possible paths
(= (BC.drive $kb $goal $initial-state $depth)
    ;; direct match from the atomspace first if this is available in the form of (Sentence ((Inheritance $initial-state (GameWin $player)) $result-stv) $result-ev)
    (let $result 
        (collapse 
            (match $kb (Sentence ((Inheritance $initial-state (GameWin $player)) $result-stv) $result-ev)
                            (Sentence ((Inheritance $initial-state (GameWin $player)) $result-stv) $result-ev)))
        (if (!= $result ())
            (ts-select $result)
            (let* (($r (collapse (pln-bc $kb $goal $initial-state $depth)))
                    ($final-result (ts-select $r)))
                        (if (== $final-result ())
                            ()
                            (let* (((Sentence ($goal $stv-final) $ev-final) $final-result)
                                    ($_ (add-atom $kb (Sentence ((Inheritance $initial-state $goal) $stv-final) $ev-final))))
                                    
                                    (Sentence ((Inheritance $initial-state $goal) $stv-final) $ev-final)))))))

        ;;   for when revison was used
        ; (if (!= $result ())
        ;     (revision $result)
        ;     (let $r (collapse (pln-bc $kb $goal $initial-state $depth))
        ;              (if (== $r ())
        ;                  ()
        ;                  (let (Sentence ($goal $stv-final) $ev-final) (revision $r)
        ;                       (Sentence ((Inheritance $initial-state $goal) $stv-final) $ev-final)))))))

;; Base Case: Depth 0. Only succeed if we strictly hit the initial state.
(= (pln-bc $kb $goal $initial-state Z)
   (if (== $goal $initial-state)
       (match $kb (Sentence ($goal $stv) $stamp) 
                  (Sentence ($goal $stv) $stamp)) ;; Wrap initial stamp in list
       (empty)))

;; Recursive Case: Superpose the strategies
(= (pln-bc $kb $goal $initial-state (S $k))
   (if (== $goal $initial-state)
       (match $kb (Sentence ($goal $stv) $stamp) 
                  (Sentence ($goal $stv) $stamp))
       (superpose (
          (win-bridge $kb $goal $initial-state (S $k))
          (modus-ponens $kb $goal $initial-state (S $k))
       ))))

;; Strategy 1: Translate (GameWin X) into a specific Board State
(= (win-bridge $kb (GameWin $player) $initial-state (S $k))
    (match $kb (Sentence ((Inheritance $winning-board (GameWin $player)) $win-stv) $win-ev)
        (case (pln-bc $kb $winning-board $initial-state $k)
            (
                ((Sentence ($returned-board $path-stv) $path-ev)
                (if (== $returned-board $winning-board)
                    (let* (($combined-stv (Truth_ModusPonens $win-stv $path-stv))
                            ($final-ev (StampConcat $path-ev $win-ev)))
                        (Sentence ((GameWin $player) $combined-stv) $final-ev))
                    (empty)))
                ($_ (empty))
            ))))

;; Strategy 2: Modus Ponens for connecting Implication Moves
(= (modus-ponens $kb $goal $initial-state (S $k))
   (match $kb (Sentence ((Implication $premise $goal) $rule-stv) $rule-ev)
       (case (pln-bc $kb $premise $initial-state $k)
          (
             ((Sentence ($returned-premise $premise-stv) $premise-ev)
              (if (== $returned-premise $premise)
                  (let* (($combined-stv (Truth_ModusPonens $rule-stv $premise-stv))
                         ($final-ev (StampConcat $premise-ev $rule-ev))
                         )
                     (Sentence ($goal $combined-stv) $final-ev))
                  (empty)))
             ($_ (empty))
          ))))

;; In-file inference test cases 
; !(pln-bc &self 
;     ;; The Goal
;     (GameWin X) 
    
;     ;; The Initial State
;     (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
    
;     ;; Depth 8 (7 Implication steps + 1 Inheritance step)
;     (S (S (S (S (S (S (S (S Z))))))))
; )

; !(BC.drive &self
;     (GameWin X) 
;     (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) 
;    (S (S (S (S (S (S (S (S Z))))))))
; )
; !(min-stv)
; !(match &self (Sentence (($link $board (GameWin X)) $stv) $stamp) $stamp)