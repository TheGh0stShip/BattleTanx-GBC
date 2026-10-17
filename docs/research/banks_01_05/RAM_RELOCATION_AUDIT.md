# RAM-executed images

There are 33 code images and 5 data images project-wide, matching the tracer.
Banks `$01`/`$02` hold 28 + 4 code images; two bank-`$01` images are callerless
one-byte no-op stubs. Banks `$03`-`$05` hold none. Every copy length equals its
ROM span.

## Installers

| Installer | Images | Copy routine |
| --- | --- | --- |
| `InstallMenuRamCode` (`$01:5867`) | `$D56A`, `$D62A`, `$D70A`, `$D7CA` (data), `$D7CB`, `$D9CB`, `$D88B`, `$D91B` | CopyBytes |
| `InstallSceneRamCode` (`$01:6618`, SVBK = 1) | 16 images, `$D000-$D3D8` | CopyBytes |
| `InstallMenuInterruptHandlers` (`$01:4B4A`) | `MenuStatHandler` -> `$C729`, `MenuVBlankHandler` -> `$C7F1` | CopyBytesShort |
| `InstallSceneInterruptHandlers` (`$01:5E6C`) | scene STAT/VBlank -> `$C729`/`$C7F1` | CopyBytes |
| `InstallPaletteStatInterruptHandlers`, `InstallVBlankOnlyInterruptHandlers` (bank `$02`) | the bank `$02` pairs | CopyBytes |

`$C729` and `$C7F1` each hold four alternative images, as `LOAD UNION`.

## Source and run-time labels

- **Copy sources** are ROM-side labels: `Bank01RomImage_XXXX` /
  `Bank02RomImage_XXXX`, placed before each `LOAD`. Labels inside a `LOAD`
  keep their RAM addresses.
- **Calls into ROM copies**: two RAM routines call the ROM copy of another
  image rather than its RAM copy. They now use ROM-side labels:
  - `call Bank01RomImage_5F26`;
  - `call Bank01RomImage_5EE0`.

  Both work because bank `$01` is mapped at the time and the callees do not
  branch internally.
- **Callerless no-op images**: installers explicitly copy exactly one `$C9`
  opcode to `$D7CA` and `$D260`, excluding the following zero byte in both
  cases. They are represented as `ret` instructions, but no direct, pointer,
  or traced indirect reference to either destination exists.

## Bank assumptions

- **Must run from RAM**: `$D000` (fixed-scene loader), `$D88B` and `$D7CB`
  switch the ROM bank.
- **Need bank `$01` mapped**: `$D56A`, `$D62A`, `$D70A`, `$D330` and both
  bank-`$01` handler pairs call bank-`$01` routines.
- **Menu VBlank handler**: saves the bank and maps bank `$01` itself.
- **Scene VBlank handler**: calls `StartSceneTileRowHdma` (`$01:6580`) without
  mapping bank `$01`. The scene STAT handler calls `Bank01RomImage_5EE0`, and
  `StepSceneWindowSplit` (`$D140`) calls `Bank01RomImage_5F26`, the same way.
  The call set is pinned by `tools/banks_01_05.py`; the invariant and the
  timing-dependent sites are in UNRESOLVED.md item 1.
