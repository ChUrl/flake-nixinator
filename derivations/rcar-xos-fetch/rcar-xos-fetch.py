#!/usr/bin/env python3
"""Print derivations/rcar-xos/versions.nix entries for R-Car xOS SDK versions.

1. Shows the SDK versions on the Renesas Artifactory and in versions.nix,
   whether their archives are in the store yet, and which ones the wslren home
   config installs.
2. Lets you pick versions (curses checklist).
3. Downloads only the *_archiver.SHA512 files of the four archives, plus the
   first few KB of the Poky archive to detect the Poky release.
4. Prints the blocks to paste into derivations/rcar-xos/versions.nix.

The archives themselves are downloaded by Nix when the rcar-xos_v<x>_<y>_<z>
package is built (builtin:fetchurl with the netrc from system/wslren).

The access token is read from a file (the sops secret), never from argv.
"""

import argparse
import base64
import concurrent.futures
import curses
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path

PLATFORM_URL = "https://artifactory.global.renesas.com/"
ARTIFACTORY_URL = PLATFORM_URL + "artifactory/"
REPO_BASE = "rcar-release/release/xos4"

# Keep in sync with derivations/rcar-xos/default.nix
ARCHIVES = {
    "sdk1": ("internal", "rcar-xos_platform-sdk1_v{v}_release.tar.gz"),
    "sdk3": ("internal", "rcar-xos_platform-sdk3_v{v}_release.tar.gz"),
    "bsp": ("rcar-tools", "rcar-xos_tool_linux_bsp_v{v}_release.tar.gz"),
    "poky": ("rcar-tools/ubuntu", "rcar-xos_tool_poky_toolchain_ubuntu_v{v}_release.tar.gz"),
}


def sha_name(archive_name: str) -> str:
    return archive_name.removesuffix(".tar.gz") + "_archiver.SHA512"


def die(msg: str) -> "None":
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def version_key(v: str):
    return [int(p) if p.isdigit() else p for p in re.split(r"[.]", v)]


# --------------------------------------------------------------------------- jfrog


class JFrog:
    """jfrog-cli with a throwaway config dir, so the token stays out of argv and ~/.jfrog."""

    def __init__(self, token: str):
        self.home = tempfile.mkdtemp(prefix="rcar-xos-jf-")
        os.chmod(self.home, 0o700)
        conf = {
            "servers": [
                {
                    "serverId": "renesas",
                    "url": PLATFORM_URL,
                    "artifactoryUrl": ARTIFACTORY_URL,
                    "accessToken": token,
                    "isDefault": True,
                }
            ],
            "version": "6",
        }
        path = Path(self.home, "jfrog-cli.conf.v6")
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "w") as f:
            json.dump(conf, f)
        self.env = os.environ | {
            "JFROG_CLI_HOME_DIR": self.home,
            "JFROG_CLI_AVOID_NEW_VERSION_WARNING": "TRUE",
            "JFROG_CLI_REPORT_USAGE": "false",
            "JFROG_CLI_HIDE_SURVEY": "true",
        }

    def cleanup(self):
        shutil.rmtree(self.home, ignore_errors=True)

    def search(self, pattern: str) -> list[dict]:
        p = subprocess.run(
            ["jf", "rt", "search", pattern],
            env=self.env,
            capture_output=True,
            text=True,
        )
        if p.returncode != 0:
            raise RuntimeError(f"jf rt search {pattern} failed:\n{p.stderr.strip()}")
        return json.loads(p.stdout or "[]")



def http_open(token: str, path: str):
    """Streaming GET of a repository path (token in a header, not in argv)."""
    req = urllib.request.Request(ARTIFACTORY_URL + path, headers={"Authorization": f"Bearer {token}"})
    try:
        return urllib.request.urlopen(req, timeout=60)
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"GET {path}: HTTP {e.code} {e.reason}") from None
    except urllib.error.URLError as e:
        raise RuntimeError(f"GET {path}: {e.reason}") from None


def remote_versions(jf: JFrog) -> dict[str, set[str]]:
    """version -> set of archive kinds present on Artifactory."""
    found: dict[str, set[str]] = {}

    def one(kind):
        folder, name = ARCHIVES[kind]
        pattern = f"{REPO_BASE}/*/{folder}/{name.format(v='*')}"
        prefix, suffix = name.split("{v}")
        rx = re.compile(
            re.escape(f"{REPO_BASE}/v") + r"(?P<v>[^/]+)/" + re.escape(f"{folder}/{prefix}") + r"(?P=v)" + re.escape(suffix) + "$"
        )
        out = []
        for item in jf.search(pattern):
            m = rx.match(item.get("path", ""))
            if m:
                out.append(m["v"])
        return kind, out

    with concurrent.futures.ThreadPoolExecutor(len(ARCHIVES)) as ex:
        for kind, versions in ex.map(one, ARCHIVES):
            for v in versions:
                found.setdefault(v, set()).add(kind)
    return found


# --------------------------------------------------------------------------- local state


def load_versions_nix(path: Path) -> dict:
    p = subprocess.run(
        ["nix", "eval", "--json", "--file", str(path)],
        capture_output=True,
        text=True,
    )
    if p.returncode != 0:
        die(f"could not evaluate {path}:\n{p.stderr.strip()}")
    return json.loads(p.stdout)


def enabled_versions(home_nix: Path) -> list[str]:
    """Versions referenced as rcar-xos_v4_40_0 in the home config."""
    try:
        text = home_nix.read_text()
    except OSError:
        return []
    return [m.replace("_", ".") for m in re.findall(r"rcar-xos_v(\d+(?:_\d+)*)", text)]


def fixed_path(sri: str, name: str) -> str | None:
    p = subprocess.run(
        ["nix-store", "--print-fixed-path", "sha512", sri, name],
        capture_output=True,
        text=True,
    )
    return p.stdout.strip() if p.returncode == 0 else None


def store_status(version: str, hashes: dict) -> int:
    """Number of the four archives of this version that are in the store."""
    n = 0
    for kind, (_, name) in ARCHIVES.items():
        sri = hashes.get(kind)
        path = sri and fixed_path(sri, name.format(v=version))
        if path and os.path.exists(path):
            n += 1
    return n


# --------------------------------------------------------------------------- tui


@dataclass
class Row:
    version: str
    remote: set[str] = field(default_factory=set)
    in_versions_nix: bool = False
    in_store: int = 0
    enabled: bool = False

    @property
    def selectable(self) -> bool:
        return len(self.remote) == len(ARCHIVES)

    def describe(self) -> str:
        cols = [
            f"v{self.version:<12}",
            f"remote {len(self.remote)}/4" if self.remote else "remote  -  ",
            "versions.nix" if self.in_versions_nix else "            ",
            f"store {self.in_store}/4" if self.in_versions_nix else "         ",
            "installed" if self.enabled else "",
        ]
        return "  ".join(cols)


def checklist(stdscr, rows: list[Row]) -> list[Row] | None:
    curses.curs_set(0)
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_GREEN, -1)
    curses.init_pair(2, 8 if curses.COLORS > 8 else curses.COLOR_WHITE, -1)
    curses.init_pair(3, curses.COLOR_CYAN, -1)

    selected: set[int] = set()
    cur = next((i for i, r in enumerate(rows) if r.selectable), 0)
    top = 0
    header = [
        "R-Car xOS SDKs   (space: toggle, enter: download selected, q: quit)",
        "Greyed out versions miss one of the four archives on Artifactory.",
        "",
    ]
    while True:
        stdscr.erase()
        h, w = stdscr.getmaxyx()
        for y, line in enumerate(header):
            stdscr.addnstr(y, 0, line, w - 1, curses.A_BOLD if y == 0 else 0)
        body = max(1, h - len(header) - 1)
        top = min(max(top, cur - body + 1), cur)
        for y, i in enumerate(range(top, min(len(rows), top + body))):
            r = rows[i]
            mark = "[x]" if i in selected else ("[ ]" if r.selectable else "   ")
            attr = 0
            if not r.selectable:
                attr |= curses.color_pair(2)
            elif r.enabled:
                attr |= curses.color_pair(1)
            elif r.in_versions_nix:
                attr |= curses.color_pair(3)
            if i == cur:
                attr |= curses.A_REVERSE
            stdscr.addnstr(len(header) + y, 0, f" {mark} {r.describe()}", w - 1, attr)
        stdscr.addnstr(h - 1, 0, f"{len(selected)} selected", w - 1, curses.A_DIM)
        stdscr.refresh()

        k = stdscr.getch()
        if k in (ord("q"), 27):
            return None
        if k in (curses.KEY_UP, ord("k")):
            cur = max(0, cur - 1)
        elif k in (curses.KEY_DOWN, ord("j")):
            cur = min(len(rows) - 1, cur + 1)
        elif k == curses.KEY_PPAGE:
            cur = max(0, cur - body)
        elif k == curses.KEY_NPAGE:
            cur = min(len(rows) - 1, cur + body)
        elif k in (curses.KEY_HOME, ord("g")):
            cur = 0
        elif k in (curses.KEY_END, ord("G")):
            cur = len(rows) - 1
        elif k == ord(" "):
            if rows[cur].selectable:
                selected ^= {cur}
            cur = min(len(rows) - 1, cur + 1)
        elif k in (curses.KEY_ENTER, 10, 13):
            return [rows[i] for i in sorted(selected)]


# --------------------------------------------------------------------------- hashes


def parse_sha_file(text: str, archive_name: str) -> str:
    for line in text.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parts[-1].lstrip("*") == archive_name:
            return parts[0].lower()
    parts = text.split()
    if parts and re.fullmatch(r"[0-9a-fA-F]{128}", parts[0]):
        return parts[0].lower()
    raise RuntimeError(f"no sha512 for {archive_name} in {sha_name(archive_name)}")


def to_sri(hexdigest: str) -> str:
    return "sha512-" + base64.b64encode(bytes.fromhex(hexdigest)).decode()


def poky_version(fileobj) -> str | None:
    """Release of the Poky SDK installer, e.g. 6.0 for ...-toolchain-6.0.sh.

    The installer is one of the first members, so the streamed read stops
    after a few KB instead of downloading the whole archive.
    """
    rx = re.compile(r"toolchains/poky/poky-[^/]*-toolchain-(\d+)\.(\d+)[^/]*\.sh$")
    with tarfile.open(fileobj=fileobj, mode="r|gz") as tar:
        for member in tar:
            m = rx.search(member.name)
            if m:
                return f"{m[1]}.{m[2]}"
    return None


def hash_version(token: str, version: str) -> dict:
    entry = {}
    for kind, (folder, name_t) in ARCHIVES.items():
        name = name_t.format(v=version)
        remote = f"{REPO_BASE}/v{version}/{folder}"
        with http_open(token, f"{remote}/{sha_name(name)}") as r:
            entry[kind] = to_sri(parse_sha_file(r.read().decode(), name))
        if kind == "poky":
            with http_open(token, f"{remote}/{name}") as r:
                entry["pokyVersion"] = poky_version(r)
    return entry


def nix_block(version: str, entry: dict) -> str:
    poky = entry.get("pokyVersion")
    poky_line = f'"{poky}"' if poky else '"FIXME"; # could not detect the Poky release'
    if poky:
        poky_line += ";"
    lines = [
        f'  "{version}" = {{',
        "    # Poky release shipped in this version, selects cmake/toolchain_poky_<x>_<y>.cmake",
        f"    pokyVersion = {poky_line}",
    ]
    lines += [f'    {k} = "{entry[k]}";' for k in ARCHIVES]
    lines.append("  };")
    return "\n".join(lines)


# --------------------------------------------------------------------------- main


def main():
    flake = Path(os.environ.get("NH_FLAKE") or os.environ.get("FLAKE") or Path.home() / "NixFlake")
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument(
        "--token-file",
        type=Path,
        default=Path(os.environ.get("RCAR_XOS_TOKEN_FILE", "/run/secrets/artifactory-token")),
        help="file containing the Artifactory access token (default: %(default)s)",
    )
    ap.add_argument("--flake", type=Path, default=flake, help="flake checkout (default: %(default)s)")
    ap.add_argument("--list", action="store_true", help="only print the table, no TUI")
    args = ap.parse_args()

    versions_nix = args.flake / "derivations/rcar-xos/versions.nix"
    home_nix = args.flake / "home/christoph/wslren/default.nix"

    try:
        token = args.token_file.read_text().strip()
    except OSError as e:
        die(f"cannot read token file {args.token_file}: {e.strerror}")
    if not token:
        die(f"token file {args.token_file} is empty")
    if not shutil.which("jf"):
        die("jfrog-cli (jf) is not on PATH")

    known = load_versions_nix(versions_nix) if versions_nix.exists() else {}
    enabled = set(enabled_versions(home_nix))

    jf = JFrog(token)
    try:
        print("Querying Artifactory ...", file=sys.stderr)
        try:
            remote = remote_versions(jf)
        except RuntimeError as e:
            die(str(e))

        rows = {}
        for v in set(remote) | set(known) | enabled:
            rows[v] = Row(
                version=v,
                remote=remote.get(v, set()),
                in_versions_nix=v in known,
                in_store=store_status(v, known[v]) if v in known else 0,
                enabled=v in enabled,
            )
        ordered = sorted(rows.values(), key=lambda r: version_key(r.version), reverse=True)

        if args.list:
            for r in ordered:
                print(r.describe())
            return

        chosen = curses.wrapper(checklist, ordered)
        if not chosen:
            print("Nothing selected.")
            return

        entries = {}
        failed = []
        for r in chosen:
            print(f"==> v{r.version}", file=sys.stderr)
            try:
                entries[r.version] = hash_version(token, r.version)
            except (RuntimeError, OSError, tarfile.TarError) as e:
                print(f"error: v{r.version}: {e}", file=sys.stderr)
                failed.append(r.version)
    finally:
        jf.cleanup()

    if entries:
        print(f"\n# Add to {versions_nix}:")
        for v in sorted(entries, key=version_key):
            if v in known and {k: known[v].get(k) for k in entries[v]} == entries[v]:
                print(f"#   v{v} is already up to date in versions.nix")
                continue
            print(nix_block(v, entries[v]))
        print(f"\n# and install them in {home_nix}, e.g. pkgs.rcar-xos_v{v.replace('.', '_')}.")
    if failed:
        die("failed: " + ", ".join(f"v{v}" for v in failed))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)
