!(import! &self "run_evolution.py")

!(py-call (run_evolution.run_moses (Board (X E E E O E E E E)) X 1))
!(import! &self policies)
!(py-call (run_evolution.clean_file "policies.metta"))

!(match &self $x $x)

!(println! "")

!(py-call (run_evolution.run_moses (Board (X E E E O E E E E)) X 2 2))
!(import! &self policies)
;; !(py-call (run_evolution.clean_file "policies.metta"))
!(match &self $x $x)

;; Write the main loop using PLN and GP.
;;
;; Takes an initial game state and starts the loop.
;; Searches the current belief and perception to find the next best move.
;; If PLN fails to find the next best move call the GP with 2 as it's maximum depth.
;; Load from the file into a belief space.
;; Rerun the PLN now on the newly introduced game moves.
;; Repeat the above two steps until PLN finds the best solution
