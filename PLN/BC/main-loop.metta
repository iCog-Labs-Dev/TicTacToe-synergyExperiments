;; Base case
(= (pln-bc $kb $goal Z $ev)
   (eval (step-lookup $kb $goal)))
   
(= (pln-bc $kb $goal (S $k) $ev)
   ;; setup direct lookup for the goal sentence 
   (let $direct-lookup (collapse 
         (match $kb (Sentence ($goal $stv) $stamp) 
            (Sentence ($goal $stv) $stamp)))
         (if (!= $direct-lookup ())
               (superpose $direct-lookup) ;; to stay consistent with the logic below which is a superposition of all the possible results
               (superpose 
                     (
                        ; (step-lookup $kb $goal)
                        (eval (modus-ponens $kb $goal (S $k) $ev))
                        (eval (syllo-deduction $kb $goal (S $k) $ev))
                        (eval (inversion $kb $goal (S $k) $ev))
                        (eval (induction $kb $goal (S $k) $ev))
                        (eval (abduction $kb $goal (S $k) $ev))
                     )))))


;; I didnt see the use of a revision rule here since all the different paths that lead to the goal get collected in one stamp tuple, it's of no use the user
;; So instead it is better to just select the best out of the paths found so far                  
(= (bc-drive $kb $goal $stamp)
   (let $result 
         (collapse (let (Sentence ($goal ($stv $s $c)) $evidence) (pln-bc $kb $goal (S (S (S Z))) $stamp)
            (if (< $c 0.1)
               (empty)
               (Sentence ($goal ($stv $s $c)) $evidence))))
            (if (!= $result ())
               (let $sorted (sorT $result) (car-atom $sorted))
               ; (empty))))            
               ())))            
                              