(= (step-lookup $kb $goal)
   (match $kb (Sentence ($goal $stv) $ev)
         (Sentence ($goal $stv) $ev)))