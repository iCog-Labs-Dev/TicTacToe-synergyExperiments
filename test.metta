!(import! &self ./PLN/pln)

!(import! &self ./PLN/BC/utilities/helpers)
!(import! &self ./PLN/BC/inversion)
!(import! &self ./PLN/BC/abduction)
!(import! &self ./PLN/BC/lookup)
!(import! &self ./PLN/BC/modus-ponens)

!(import! &self ./PLN/BC/syllogisitic-deduction)
!(import! &self ./PLN/BC/induction)

!(import! &self ./PLN/BC/main-loop)
!(import! &self "run_evolution.py")

; !(py-call (run_evolution.is_full (E E E E E E E E E)))
; !(py-call (run_evolution.is_full (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))))
; !(match &self (= (modus-ponens $kb $g (S $s) $ev) $body) $body)
; !(match &self (= (inversion $kb $g (S $s) $ev) $body) $body)

!(bind! &kb (new-space))
!(add-atom &kb (Sentence ((Inheritance animal cat) (stv 0.6 0.7)) (1)))

!(add-atom &kb (Sentence (cat (stv 0.7 0.8)) (2)))


!(inversion &kb (Inheritance cat animal) (S (S Z)) ())  
!(+ 1 2)
; !(match &self (= (induction $kb $goal $depth $ev) $body) $body)
!(match &self (= (induction $kb $goal $depth $ev) $body) $body)
