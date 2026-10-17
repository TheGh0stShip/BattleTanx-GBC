#!/usr/bin/env python3
"""Optional CGB rendering smoke test using PyBoy 2.8.1.

This is confirmatory runtime evidence, not part of the byte-match gate and not
a substitute for physical-hardware testing.
"""
from __future__ import annotations

import argparse
import hashlib
import importlib.metadata
import pathlib


EXPECTED_SHA1 = "5078584e86c0b6f4687c424cc00bbd762ba6573a"
CHECK_FRAMES = (120, 360, 720, 1200, 1800)
PRESS_A_FRAMES = (180, 360, 540, 720, 900)


def chromatic_pixels(rgb) -> int:
    flat = rgb.reshape((-1, rgb.shape[-1]))
    return int(((flat.max(axis=1) - flat.min(axis=1)) > 8).sum())


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("rom", nargs="?", default="battletanx.gbc")
    args = parser.parse_args()
    path = pathlib.Path(args.rom)
    data = path.read_bytes()
    got = hashlib.sha1(data).hexdigest()
    if got != EXPECTED_SHA1:
        raise SystemExit(f"{path}: SHA-1 {got}, expected {EXPECTED_SHA1}")

    try:
        from pyboy import PyBoy
    except ImportError as exc:
        raise SystemExit("PyBoy 2.8.1 is required: python3 -m pip install PyBoy==2.8.1") from exc
    version = importlib.metadata.version("pyboy")
    if version != "2.8.1":
        raise SystemExit(f"PyBoy {version} installed, expected 2.8.1")

    pyboy = PyBoy(str(path), window="null", sound_emulated=False)
    pyboy.set_emulation_speed(0)
    observations = {}
    try:
        for frame in range(1, CHECK_FRAMES[-1] + 1):
            if frame in PRESS_A_FRAMES:
                pyboy.button("a")
            render = frame in CHECK_FRAMES
            pyboy.tick(1, render=render, sound=False)
            if render:
                rgb = pyboy.screen.ndarray[:, :, :3]
                observations[frame] = (len({tuple(x) for row in rgb for x in row}), chromatic_pixels(rgb))
    finally:
        pyboy.stop(save=False)

    # Early boot art may be monochrome. These later checkpoints prove that the
    # CGB palette path is active and that rendering is not stuck in greyscale.
    for frame, minimum in ((720, 1000), (1200, 10000), (1800, 20000)):
        colours, chromatic = observations[frame]
        if chromatic < minimum:
            raise SystemExit(f"frame {frame}: only {chromatic} chromatic pixels (expected >= {minimum})")
    for frame in CHECK_FRAMES:
        colours, chromatic = observations[frame]
        print(f"frame {frame}: {colours} RGB colours, {chromatic} chromatic pixels")
    print("emulator smoke: PASS (CGB colour rendering confirmed; physical hardware not tested)")


if __name__ == "__main__":
    main()
