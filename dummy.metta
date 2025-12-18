!(import! &self "run_evolution.py")

!(py-call (run_evolution.run_moses (Board (X E E E O E E E E)) X 1))
!(import! &self policies)
!(py-call (run_evolution.clean_file "policies.metta"))

!(match &self $x $x)

!(println! "")

!(py-call (run_evolution.run_moses (Board (X E E E O E E E E)) X 2 2))
!(import! &self policies)
!(py-call (run_evolution.clean_file "policies.metta"))
!(match &self $x $x)
