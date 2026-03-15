!(import! &self ./tests/game-data)
!(import! &self ../pln)
!(import! &self ./thompson-select)

(= (syllo-deduction $kb ($LinkType $A $C) $initial-node Z)
   (match $kb (Sentence (($LinkType $A $C) $stv) $stamp) 
              (Sentence (($LinkType $A $C) $stv) $stamp)))

;; Recursive Case: Chain ANY two links together
(= (syllo-deduction $kb ($LinkTypeAC $A $C) $initial-node (S $k))
   (superpose (
      ;; Check if the exact relationship already exists
      (match $kb (Sentence (($LinkTypeAC $A $C) $stv) $stamp) 
                 (Sentence (($LinkTypeAC $A $C) $stv) $stamp))
      
      ;; THE MAGIC: Match ANY link type ($LinkTypeBC) connecting B to C
      (match $kb (Sentence (($LinkTypeBC $B $C) $stv-bc) $rule-ev)
         
         ;; RECURSE: Find ANY link type ($LinkTypeAB) connecting A to B
         (case (syllo-deduction $kb ($LinkTypeAB $A $B) $initial-node $k)
            (
               ((Sentence (($LinkTypeAB $A $B) $stv-ab) $path-ev)
                
                ;; Synthesize the final macro-link (MeTTa resolves $LinkTypeAC dynamically)
                (Sentence (($LinkTypeAC $A $C) (Truth_Deduction $stv-ab $stv-bc)) (StampConcat $path-ev $rule-ev)))
               ($__1 (empty))
            )
         )
      )
   ))
)

;; ============================================================
;; 3. THE SMART WRAPPER
;; ============================================================
(= (pln-bc $kb $goal-node $initial-node $depth)
   ;; We pass an unbound variable $LinkType to the deduction engine
   (case (syllo-deduction $kb ($LinkType $initial-node $goal-node) $initial-node $depth)
      (
         ;; We catch whatever macro-link it built, strip the link, and return the Node!
         ((Sentence (($LinkType $start $end) $combined-stv) $final-path)
          (Sentence ($goal-node $combined-stv) $final-path))
         ($__2 (empty))
      )
   )
)

;; use thomson sampling to 
(= (BC.drive $kb $goal-node $initial-node $depth)
   (let $sentences (collapse (pln-bc $kb $goal-node $initial-node $depth))
      (ts-select $sentences)))

;; ============================================================
;; 4. KNOWLEDGE BASE (Mixed Link Types)
;; ============================================================
!(add-atom &kb (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row E (Col X E)) (Rows (Row E (Col E E)) (Row E (Col E E))))) (stv 0.3 0.1667)) (519)))
!(add-atom &kb (Sentence ((Implication (Board (Row E (Col X E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row E (Col X E)) (Rows (Row E (Col E E)) (Row E (Col O E))))) (stv 0.2 0.1667)) (531)))
!(add-atom &kb (Sentence ((Inheritance (Board (Row E (Col X E)) (Rows (Row E (Col E E)) (Row E (Col O E)))) (GameWin X)) (stv 0.9 0.9)) (46)))

;; ============================================================
;; 5. THE QUERY (Exactly how you want it!)
;; ============================================================
; !(println! "--- Running Link-Agnostic Smart Deduction ---")
; !(pln-bc &kb 
;     (GameWin X)
;     (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) 
;     (S (S (S Z))) ;; Depth 3
; )

; !(println! "--- Running Link-Agnostic Smart Deduction from game data---")
; !(pln-bc &self 
;     (GameWin X) 
    ; (Board (Row X (Col O X)) (Rows (Row O (Col E E)) (Row E (Col E E)))) ;; A mid-game board
;     (S (S (S (S (S (S Z)))))) ;; Only needs Depth 6 to finish the remaining deep game
; )


; !(println! "--- Running GUARANTEED Mid-Game Macro-Rule Synthesis ---")
; !(pln-bc &self 
;     ;; THE GOAL NODE
;     (GameWin X) 
    
;     ;; THE INITIAL NODE (The exact board right before Stamp 511)
;     (Board (Row X (Col O E)) (Rows (Row E (Col E E)) (Row X (Col E E))))
    
;     ;; DEPTH 5 (Needs to bridge 511 -> 512 -> 515 -> 516 -> 2)
;     (S (S (S (S (S Z))))) 
; )

!(println! "--- Running GUARANTEED Mid-Game Macro-Rule Synthesis ---")
!(pln-bc &self 
    ;; THE GOAL NODE
    (GameWin X) 
    
    ;; THE INITIAL NODE (The exact board right before Stamp 511)
    (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
    
    ;; DEPTH 5 (Needs to bridge 511 -> 512 -> 515 -> 516 -> 2)
    (S (S (S (S (S (S (S (S (S Z))))))))) 
)

; !(BC.drive &self 
;     ;; THE GOAL NODE
;     (GameWin X) 
    
;     ;; THE INITIAL NODE (The exact board right before Stamp 511)
;     (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
    
;     ;; DEPTH 5 (Needs to bridge 511 -> 512 -> 515 -> 516 -> 2)
;     (S (S (S (S (S (S (S (S (S Z))))))))) 
; )
