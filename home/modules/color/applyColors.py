import fileinput
import re
from typing import Callable

# This dict gets defined before.
# The code is templated by nix to fill the color values automatically.
# colors: dict[str, str] = {
#     "rosewater": "f5e0dc",
#     "flamingo": "f2cdcd",
# }
colors: dict[str, str]


def getRule(
    line: str,
    value: str,
) -> Callable[[str, str, str], str] | None:
    """Obtain a substitution rule for a line"""

    # This contains each rule assigned to a pattern
    rules: dict[str, Callable[[str, str, str], str]] = {
        # "#ffffff" -> ${color.hexS.white}
        f'"#{value}"': lambda line, name, value: line.replace(
            f'"#{value}"', f"${{color.hexS.{name}}}"
        ),
        # '#ffffff' -> ${color.hexS.white}
        f"'#{value}'": lambda line, name, value: line.replace(
            f"'#{value}'", f"${{color.hexS.{name}}}"
        ),
        # #ffffff -> ${color.hexS.white}
        f"#{value}": lambda line, name, value: line.replace(
            f"#{value}", f"${{color.hexS.{name}}}"
        ),
        # "ffffff" -> ${color.hex.white}
        f'"{value}"': lambda line, name, value: line.replace(
            f'"{value}"', f"${{color.hex.{name}}}"
        ),
        # 'ffffff' -> ${color.hex.white}
        f"'{value}'": lambda line, name, value: line.replace(
            f"'{value}'", f"${{color.hex.{name}}}"
        ),
        # ffffff -> ${color.hex.white}
        f"{value}": lambda line, name, value: line.replace(
            f"{value}", f"${{color.hex.{name}}}"
        ),
        # "#${color.hex.white}" -> ${color.hexS.white}
        '"#${color.hex."': lambda line, name, value: line.replace(
            '"#${color.hex."', "${color.hexS.}"
        ),
        # ff,ff,ff -> ${color.rgbS.white}
        f"{value[0:2]},{value[2:4]},{value[4:6]}": lambda line, name, value: line.replace(
            f"{value[0:2]},{value[2:4]},{value[4:6]}", f"${{color.rgbS.{name}}}"
        ),
    }

    for pattern, rule in rules.items():
        # If the line matches the pattern, use this rule
        if len(re.findall(pattern, line, re.IGNORECASE)) > 0:
            return rule

    return None


def applyColorToLine(
    line: str,
    name: str,
    value: str,
) -> str:
    """Apply a single color to a single line"""
    result: str = line

    rule: Callable[[str, str, str], str] | None = getRule(result, value)
    while rule is not None:
        result = rule(line, name, value)

        # We apply rules until no rule can be applied anymore
        rule = getRule(result, value)

    return result


def applyColorsToLine(
    line: str,
) -> None:
    """Apply all defined colors to a single line"""
    result: str = line
    for name, value in colors.items():
        result = applyColorToLine(result, name, value)

    # Print to stdout
    print(result)


# Apply transformation to every line from stdin
for line in fileinput.input():
    applyColorsToLine(line.rstrip())
