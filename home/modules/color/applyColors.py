import fileinput

colors: dict[str, str]
# colors: dict[str, str] = {
#     "rosewater": "f5e0dc",
#     "flamingo": "f2cdcd",
# }


def applyColorToLine(line: str) -> None:
    print(f"{line} # piped")


# Apply transformation to every line from stdin
for line in fileinput.input():
    applyColorToLine(line)
