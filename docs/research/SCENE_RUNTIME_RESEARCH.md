# Scene runtime: banks $2F-$3A

Baseline `ae8696ef6adf28ad6984acbb64a9954d4cca854c`. Bank `$3B` is excluded.
Layout and checks: `tools/check_project.py` fixed/scrolling scene checks and
`tools/gen_*_scene_asm.py`.

## Index route

- **Fixed index**: `$FF81`. `CopyFixedSceneDescriptor` (`$01`) copies `idx*16`
  to `$D3E0`, then `LoadFixedSceneResources` loads it.
- **Scrolling index**: `$FF82`. `CopyScrollingSceneDescriptor` copies `idx*8`
  to `$D3F0`, then `LoadScrollingScenePalette` (RAM `$D160`) loads it.

The only callers are `RunScrollingScene`, `RunMenuGridSceneScroll`, `LoadFixedSceneForRow` and
`LoadScrollVariantForGridCell`.

| Fixed | Writer | Scroll | Writer |
| --- | --- | --- | --- |
| 0 | `RunLevelExitScreenFlow` | 0 | `RunLevelExitScreenFlow` |
| 1-5 | `SelectLevelRowScene` (levels 0/3/6/9/12 via `$01:$6609`, world w = `$65EB[2L]`) | 1-5 | same |
| 6-10 | `SelectLevelScene` (`SceneDescriptorIndexTable[w]`, *verified*) and menu row (`6309`) | 6-`$14` | `63D1` (`SceneScrollDescriptorIndexTable[4w+c]`, *verified*) and menu confirm (`6247`) |
| | | `$15-$23` | menu preview `6367` (`SceneScrollVariantIndexTable`, *verified*) |

- Every descriptor index is produced; none is unused.
- Table slots 3/7/11/15 (zeros) would need column c = 3. The column is
  clamped to 0-2 (`SetMenuGridColumnClamped`) and every `$65EB` column is at most 2, so
  those slots are never selected.
- Scenes are grouped per world (5 worlds x 3 levels). No scene is named,
  because no encoded text identifies one.

## Scrolling behaviour

- **Rows**: 40 bytes, 20 x 16-bit tile indices.
- **Speed**: `AdvanceSceneScroll` advances SCY by `$FF97` (1 px/frame, set by
  `InitSceneDisplay`) and streams one row every 8 px into a 7-slot VRAM ring
  (`ScrollingTileRowDestinations`).
- **Initial row**: 0 for previews; `SceneScrollInitialRowTable` (`$13`/`$14`,
  *verified*) on confirm.
- **End**: the scene ends when `$FF8B` reaches the descriptor's last row
  (`$FF84` = 1).
- **Previews** (last row 5) draw 6 rows at once.
- **Mutation**: rows and tiles are never modified in place. The palette is
  copied to `$DC48` and processed by `BuildScenePaletteFadeTable`.

## Dual-use bytes (5,872) and over-reads

- **Dual-use**: the fixed loader always transfers 255 tiles by HDMA (`$7F` +
  `$7E` blocks, 4,080 bytes) from each scene's tile pointer. The tile window
  therefore covers that scene's own map, attributes and palettes (4,936 +
  320 bytes) and, in three places, neighbouring scenes:
  - F10 over F01 tiles, 1,056 bytes;
  - F09 over F10, 64 bytes;
  - F08 palette over F09 tiles, 16 bytes.

  Both readers really read these bytes. The tile copies land in VRAM that is
  presumably never displayed; that part is inferred.
- **Over-reads**:
  - The fixed loader also copies 8 bytes from palettes + `$38` to `$DC40`
    whatever the count (*verified*). For F00/F01/F08/F10 this lies outside
    the counted palettes; for F08 it reads 8 bytes of F09's tiles.
  - F04's count of 9 copies 72 bytes into the 64-byte buffer at `$D7C0`,
    reaching `$D807`. The effect is unknown.
  - Scrolling palettes are exactly 8 bytes, with no over-read.

## Relocation

- **Fixed descriptors** (`$01:SceneBackgroundDescriptors`): symbolic
  addresses, raw bank bytes. In banks `$30-$33`:
  - the absolute `ASSERT @ == $xxxx` lines were replaced by
    `ASSERT BANK(label) == $3x` for every scene label;
  - every fixed tile source has an `ASSERT (label & $0F) == 0` (HDMA
    requires 16-byte alignment);
  - fills became `ds $7FFF - @`;
  - markers became `db BANK(@)`.

  Shift tests: fixed scenes 06-07 and scrolling scenes 32-35 relocate (8 and
  20 pointer words); an 8-byte insertion stops at the alignment assert.
- **The raw scrolling descriptors** store raw words (bank `$01`, out of scope).
  Their 90 target words in `$2F`/`$34-$3A` are pinned by address and bank, and
  the shift test of scene 21 stops the build. Entry 0 targets bank `$3B` and
  is out of scope.
