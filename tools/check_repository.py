#!/usr/bin/env python3
"""Check public repository metadata and reject tracked build products."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REQUIRED = {
    ".recomp.json", "LICENSE", "README.md", "docs/ARCHITECTURE.md",
    "docs/PROVENANCE.md", "docs/SOURCE_MATURITY.md", "docs/STATUS.md",
    "docs/TOOLS.md", "docs/VERIFICATION.md",
}
FORBIDDEN_SUFFIXES = {".gb", ".gbc", ".map", ".o", ".pyc", ".sym"}


def fail(message: str) -> None:
    raise SystemExit(f"repository: {message}")


def main() -> None:
    result = subprocess.run(
        ["git", "ls-files", "-z"], cwd=ROOT, check=True, capture_output=True
    )
    tracked = {p.decode() for p in result.stdout.split(b"\0") if p}
    missing = sorted(REQUIRED - tracked)
    if missing:
        fail(f"required tracked files missing: {', '.join(missing)}")

    bad = sorted(
        path for path in tracked
        if Path(path).suffix.lower() in FORBIDDEN_SUFFIXES
        or path.startswith("build/") or "__pycache__/" in path
    )
    if bad:
        fail(f"generated or cartridge files are tracked: {', '.join(bad)}")

    root_docs = sorted(
        path for path in tracked if "/" not in path and path.lower().endswith(".md")
    )
    if root_docs != ["README.md"]:
        fail(f"unexpected root documentation: {root_docs}")

    license_text = (ROOT / "LICENSE").read_text(encoding="utf-8")
    if "GNU GENERAL PUBLIC LICENSE" not in license_text or "Version 3" not in license_text:
        fail("LICENSE is not GNU GPL version 3")

    manifest = json.loads((ROOT / ".recomp.json").read_text(encoding="utf-8"))
    # The public schema offers only recomp/port/decomp; its "decomp" value is
    # an umbrella for source rebuilt from a binary, including disassemblies.
    for key, value in {"game": "BattleTanx", "system": "GBC", "type": "decomp"}.items():
        if manifest.get(key) != value:
            fail(f".recomp.json {key!r} must be {value!r}")
    if manifest.get("x-source-form") != "byte-exact annotated assembly disassembly":
        fail(".recomp.json must identify the actual assembly source form")
    if manifest.get("status") != "complete":
        fail(".recomp.json must publish the completed reconstruction status")
    if "assembly disassembly" not in manifest.get("approach", "").lower():
        fail(".recomp.json approach must identify the actual assembly source form")
    if manifest.get("original", {}).get("sha1") != "5078584e86c0b6f4687c424cc00bbd762ba6573a":
        fail(".recomp.json has the wrong supported cartridge hash")

    print(f"repository: OK ({len(tracked)} tracked files, GPL-3.0, no tracked cartridge or build products)")


if __name__ == "__main__":
    main()
