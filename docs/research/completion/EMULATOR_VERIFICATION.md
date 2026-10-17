# Emulator verification

This is confirmatory runtime evidence for the byte-exact retail reconstruction.
It does not replace the physical-hardware tests in `HARDWARE_VERIFICATION.md`.

## Reproducible colour check

Tested with PyBoy 2.8.1 using the rebuilt cartridge whose SHA-1 is
`5078584e86c0b6f4687c424cc00bbd762ba6573a`:

```sh
python3 -m venv /tmp/battletanx-pyboy
/tmp/battletanx-pyboy/bin/pip install PyBoy==2.8.1
/tmp/battletanx-pyboy/bin/python tools/emulator_smoke.py battletanx.gbc
```

Expected output:

```text
frame 120: 2 RGB colours, 0 chromatic pixels
frame 360: 4 RGB colours, 136 chromatic pixels
frame 720: 6 RGB colours, 3543 chromatic pixels
frame 1200: 7 RGB colours, 16085 chromatic pixels
frame 1800: 8 RGB colours, 21728 chromatic pixels
emulator smoke: PASS (CGB colour rendering confirmed; physical hardware not tested)
```

The scripted A-button presses are fixed at frames 180, 360, 540, 720 and 900.
The later frames contain thousands of pixels whose RGB channels differ by more
than eight, directly refuting the earlier appearance that the game rendered
only in black and white. Screenshots are derived inspection output and are not
tracked.

## Scope

This run establishes that the reconstructed cartridge boots in CGB mode and
uses coloured palettes on the tested path. It does not establish cycle accuracy,
physical LCD appearance, interrupt timing on a cartridge, or the reachability
of the SVBK=2 hazard.
