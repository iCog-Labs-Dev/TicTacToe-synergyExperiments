(= (modus-ponens $kb $goal (S $k) $ev)
   ;; 1. Find all matching Rules
   (match $kb (Sentence (($link-type $premise $goal) $stv) $goal-ev)
      (if (and (SyllogisticRuleGuard $link-type)
                (StampDisjoint $ev $goal-ev))
              
              (let* (($next-ev (StampConcat $ev $goal-ev))
                  ;   ($_ (println! ("been here" $next-ev)))
                    ((Sentence ($premise $stv-premise) $premise-ev) (pln-bc $kb $premise $k $next-ev))
                    ($combined-stv (Truth_ModusPonens $stv $stv-premise))
                    ($evidence-list (StampConcat $premise-ev $next-ev))
                    ($_ (add-atom $kb (Sentence ($goal $combined-stv) $evidence-list))))
                  
                    (Sentence ($goal $combined-stv) $evidence-list))
                
              (empty))))