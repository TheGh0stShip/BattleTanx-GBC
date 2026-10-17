# Reproduction manual

This is the prescriptive clean-checkout build path for the supported USA cartridge.
Commands below assume Ubuntu 24.04 or Ubuntu under WSL, Bash, an x86-64 host,
and a legally obtained cartridge dump. Commands beginning with `$` are entered
verbatim without the `$` prompt.

## 1. Install host prerequisites

```console
$ sudo apt-get update
$ sudo apt-get install -y curl git make python3 xz-utils
```

Install the pinned RGBDS release locally rather than using an unpinned package:

```console
$ mkdir -p "$HOME/.local/opt/rgbds-1.0.4"
$ curl --fail --location \
    https://github.com/gbdev/rgbds/releases/download/v1.0.4/rgbds-linux-x86_64.tar.xz \
    --output /tmp/rgbds-1.0.4.tar.xz
$ tar -xJf /tmp/rgbds-1.0.4.tar.xz -C "$HOME/.local/opt/rgbds-1.0.4"
$ export PATH="$HOME/.local/opt/rgbds-1.0.4:$PATH"
$ rgbasm --version
rgbasm v1.0.4
```

Start a new shell by repeating the `export PATH=...` line or placing it in the
shell profile. Do not substitute a newer RGBDS release without separately
verifying the resulting bytes.

## 2. Clone the project

```console
$ git clone https://github.com/TheGh0stShip/BattleTanx-GBC.git
$ cd BattleTanx-GBC
$ git status --short
```

The final command prints nothing in a clean clone.

## 3. Supply and verify the cartridge

Dump your own **BattleTanx (USA)** Game Boy Color cartridge and copy it to the
project root as `baserom.gbc`:

```console
$ cp "/path/to/your/legally-obtained-file.gbc" baserom.gbc
$ python3 tools/verify_rom.py baserom.gbc
baserom.gbc: OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
$ sha256sum baserom.gbc
b449bab1b0a422fdb462d0dc5c55fbc8e50d8c18a5e2fd836e7db016ee63aa62  baserom.gbc
```

Required image properties:

| Property | Required value |
| --- | --- |
| Filename used by the build | `baserom.gbc` |
| Size | 1,048,576 bytes |
| SHA-1 | `5078584e86c0b6f4687c424cc00bbd762ba6573a` |
| SHA-256 | `b449bab1b0a422fdb462d0dc5c55fbc8e50d8c18a5e2fd836e7db016ee63aa62` |

A renamed file is acceptable; the hashes, not the original dump filename,
identify the supported image.

## 4. Recreate every binary source asset

The repository currently commits typed source assets, but the entire set can
be regenerated from the verified cartridge. This command handles both ordinary
contiguous ranges and the two bank-$08 files assembled from non-contiguous ROM
slices:

```console
$ make extract-assets
python3 tools/prepare_assets.py baserom.gbc
assets: cartridge OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
assets: prepared 158 files (0 written)
$ python3 tools/prepare_assets.py baserom.gbc --check
assets: cartridge OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
assets: verified 158 files (0 written)
```

In a source archive without `assets/`, the first command writes all 158 files.
It refuses an unsupported dump before creating an asset.

To prove this without altering the checkout:

```console
$ scratch="$(mktemp -d)"
$ python3 tools/prepare_assets.py baserom.gbc --output-root "$scratch"
assets: cartridge OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
assets: prepared 158 files (158 written)
$ diff -qr assets "$scratch/assets"
$ rm -rf "$scratch"
```

`diff` prints nothing when the recovered assets match.

## 5. Build the cartridge

```console
$ make clean
$ make battletanx.gbc
rgbasm -Werror -o build/main.o src/main.asm
rgblink -p 0xFF -n battletanx.sym -m battletanx.map -o battletanx.gbc build/main.o
$ sha1sum battletanx.gbc
5078584e86c0b6f4687c424cc00bbd762ba6573a  battletanx.gbc
$ cmp --silent baserom.gbc battletanx.gbc && echo "byte-identical"
byte-identical
```

## 6. Run the complete gate

```console
$ make check
```

The suite is intentionally verbose. Its required final facts include:

```text
battletanx.gbc: OK (sha1 5078584e86c0b6f4687c424cc00bbd762ba6573a)
rom range map: 2411 ranges, 1048576 bytes in 64 banks, no gaps or overlaps
passwords: canonical list and 245760 accepted states round-trip without collisions
source names: 288/288 named; 0 remain
repository: OK
```

The exact number of negative mutation tests is allowed to increase as checks
improve. Any nonzero exit, hash mismatch, missing range, overlap, stale report,
or failed round trip is a failure.

## 7. Reproduce the public progress report

```console
$ make report
python3 tools/bytematch_report.py --out report.json
$ python3 -m json.tool report.json >/dev/null
```

Expected aggregate measurements are:

| Category | Matched | Total |
| --- | ---: | ---: |
| Program and RAM-executed code | 39,359 | 39,359 |
| Data, assets, padding and markers | 1,009,217 | 1,009,217 |
| Functions | 288 | 288 |
| ROM banks | 64 | 64 |

These are exact-reconstruction measurements, not a claim that every gameplay
meaning is known.

## 8. Inspect decoded content

```console
$ make graphics maps levels screens objects bank08
```

Lossless PNG, CSV, JSON and palette inspection output is written below
`build/`. Each exporter reconstructs its source bytes and rejects a lossy
round trip. These files are ignored build products.

## 9. Understand the completion claim

Read these before reporting the project as complete:

1. `docs/COMPLETENESS.md` — what is and is not 100%.
2. `docs/STATUS.md` — current subsystem ledger and roadmap.
3. `docs/research/completion/UNRESOLVED.md` — evidence-backed open questions.
4. `docs/research/completion/HARDWARE_VERIFICATION.md` — tests still requiring
   emulator or physical-hardware confirmation.

The correct short description is: **100% byte-exact ROM reconstruction; full
semantic recovery is not yet complete.**
