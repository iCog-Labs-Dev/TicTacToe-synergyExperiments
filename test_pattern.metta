!(bind! &c (new-state 10))
!(let (($x)) (1) (change-state! &c $x))
!(println! (c-value (get-state &c)))
