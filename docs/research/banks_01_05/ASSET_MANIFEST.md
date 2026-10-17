# Asset manifest (banks $01-$05)

| Asset | Bank | Bytes | SHA-1 | ROM offset | Format | Status |
| --- | --- | ---: | --- | --- | --- | --- |
| `assets/bank_01/menu_cursor_sprite_tiles.2bpp` | $01 | 128 | `023fb609e5b718205114c74c47f76ecb6e87ef9a` | 0x58df | 2bpp, 8 tiles | added |
| `assets/bank_01/password_screen_tiles.2bpp` | $01 | 2064 | `f117bbd925183b67a1461834dc0471f4eb7d12b7` | 0x6e8a | 2bpp, 129 tiles (second copy overruns into the glyph table) | added |
| `assets/bank_01/sprite_tiles_7871.2bpp` | $01 | 64 | `c8d7d0ef0eedfa82d2ea1aa592845b9a6d4b02b7` | 0x7871 | 2bpp, 4 tiles | added |
| `assets/bank_01/sprite_tiles_78B1.2bpp` | $01 | 64 | `8d926825774a8e146520ef5eb7b27563d74e3c78` | 0x78b1 | 2bpp, 4 tiles | added |
| `assets/bank_02/burst_tiles.2bpp` | $02 | 528 | `fba343be08aa598ce99e869121f1c92ab2a9f7cf` | 0x9e89 | 2bpp, 33 tiles | added |
| `assets/bank_02/tracker_direction_lookup.bin` | $02 | 2048 | `bc3392db623b91add8fedead651e6343497ca4ed` | 0x9440 | nibble-packed dx/dy -> direction lookup | added |
| `assets/bank_02/unread_481E.bin` | $02 | 1332 | `9380d7e9d86d7571f6d7e24a86b83b3530a29b7a` | 0x881e | unknown, no reader | added |
| `assets/bank_05/bank04_copy_40B1.bin` | $05 | 591 | `792cffcbd524b60e0d27cf502338bde0cea167d9` | 0x140b1 | byte copy of bank $04, no reader | added |
| `assets/bank_05/bank04_copy_431E.bin` | $05 | 226 | `c6a46c321fd468fa326334348905a76eee4a1f51` | 0x1431e | byte copy of bank $04, no reader | added |
| `assets/bank_05/bank04_copy_452C.bin` | $05 | 212 | `c56bb413a4cecfa6e10d45085786ca13c571ab0a` | 0x1452c | byte copy of bank $04, no reader | added |

Removed (every byte now explicit source or a typed asset above):

| Asset | Bytes | SHA-1 | Replacement |
| --- | ---: | --- | --- |
| `assets/bank_01/58DF.bin` | 190 | `a75d94ed60171923b82c48b35755edb6b42b0773` | menu cursor tiles (asset) + tile ids, palette, picture descriptors (source) |
| `assets/bank_01/6E8A.bin` | 2663 | `4de5c9d075f323e234666d2bbaf76a4bb47daa73` | password tiles + two sprite blocks (assets) + glyph/attribute/palette/column tables, unread gaps (source) |
| `assets/bank_01/7D5D.bin` | 675 | `5e124bf19108661ec5b93d94c3ecc1cff71a5734` | `ds` fill + `db BANK(@)` |
| `assets/bank_02/481E.bin` | 1338 | `d025e46aab762189ab4575c3f7bf1740acb8bbe9` | `unread_481E.bin` + `Bank02ObjPalette7Colours` (source) |
| `assets/bank_02/5040.bin` | 3072 | `abd1fa78360b7370b2202b1a5808808c4bfb2ec1` | `TrackerPointerFrames` (source) + `tracker_direction_lookup.bin` |
| `assets/bank_02/5DE0.bin` | 1165 | `5b4fdb833d8b48c8402237dcc03d62558fe04177` | palettes, tile grids, tables (source) + `burst_tiles.2bpp` |
| `assets/bank_02/66DC.bin` | 6436 | `bde6747983763d66d3bfee56cfcac24e6a61eaee` | `ds` fill + `db BANK(@)` |
| `assets/bank_05/40B1.bin` | 591 | `792cffcbd524b60e0d27cf502338bde0cea167d9` | `bank04_copy_40B1.bin` (renamed provenance) |
| `assets/bank_05/431E.bin` | 226 | `c6a46c321fd468fa326334348905a76eee4a1f51` | `bank04_copy_431E.bin` |
| `assets/bank_05/452C.bin` | 2420 | `bea028e4bebe0382a2ad4351fc6c8ae1d8486de2` | `bank04_copy_452C.bin` ($D4 bytes) + `ObjectVelocityTable` and zero gap (source) |
| `assets/bank_05/59E0.bin` | 9760 | `af5cb34c827a99d926d9a72ffd557befe94b08e7` | `src/screen_effect_tables.asm` |
