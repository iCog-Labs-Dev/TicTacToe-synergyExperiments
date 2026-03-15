import re
import os
import glob

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # We want to replace all occurrences of $_ with $__1, $__2, etc. sequentially in the file.
    # Since each $_ is localized to its binding context in PeTTa, the exact number doesn't matter
    # as long as they are distinct within the file.
    counter = 1
    def repl(m):
        nonlocal counter
        res = f"$__{counter}"
        counter += 1
        return res
    
    # regex matches exactly $_ but not $_1 or $_something
    new_content = re.sub(r'\$_(?![a-zA-Z0-9_])', repl, content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for f in glob.glob("**/*.metta", recursive=True):
    process_file(f)
