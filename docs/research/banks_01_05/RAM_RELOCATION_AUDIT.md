# RAM-executed images

There are 31 code images and 7 data images project-wide, matching the
tracer. Banks `$01`/`$02` hold 26 + 4 code images and 2 data images. Banks
`$03`-`$05` hold none. Every copy length equals its ROM span.

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
- **Data images**: `$D7CA` and `$D260` are single `$C9` bytes with no
  reference. They are kept as data images.

## Bank assumptions

- **Must run from RAM**: `$D000` (fixed-scene loader), `$D88B` and `$D7CB`
  switch the ROM bank.
- **Need bank `$01` mapped**: `$D56A`, `$D62A`, `$D70A`, `$D330` and both
  bank-`$01` handler pairs call bank-`$01` routines.
- **Menu VBlank handler**: saves the bank and maps bank `$01` itself.
- **Scene VBlank handler**: calls `Func_01_6580` without mapping bank `$01`.
  The scene STAT handler calls `Bank01RomImage_5EE0` the same way. See
  UNRESOLVED.md.
