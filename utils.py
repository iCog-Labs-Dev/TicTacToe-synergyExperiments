import fileinput


def join_metta_strs(input_strings):
    return "\n".join(input_strings) + "\n"


def to_metta_str(input_string):
    input_string = str(input_string)
    # Converts prolog parsed MeTTa expression into MeTTa string
    return (
        input_string.replace("[", "(")
        .replace("]", ")")
        .replace(",", "")
        .replace("'", "")
    )


def remove_from_file(filename: str, targets: list):
    # 1. Convert all items in the input list to their metta string format
    converted_targets = [to_metta_str(t) for t in targets]

    removed = False

    with fileinput.input(filename, inplace=True, backup=".bak") as file:
        for line in file:
            # Check if ANY of the converted targets are inside the current line
            match_found = any(t in line for t in converted_targets)

            if not match_found:
                # If no match is found, keep the line
                print(line, end="")
            else:
                # If a match IS found, skip printing (deletes it) and mark flag
                removed = True

    return removed


def add_to_file(filename: str, content):
    with open(filename, "a") as f:
        f.write(content)

    return True
