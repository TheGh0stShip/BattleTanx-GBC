# Asset manifest (banks $01-$05)

| Asset | Bank | Bytes | SHA-1 | ROM offset | Format | Status |
| --- | --- | ---: | --- | --- | --- | --- |
| `assets/bank_01/menu_cursor_sprite_tiles.2bpp` | $01 | 128 | `023fb609e5b718205114c74c47f76ecb6e87ef9a` | 0x58df | 2bpp, 8 tiles | added |
| `assets/bank_01/password_screen_tiles.2bpp` | $01 | 2064 | `f117bbd925183b67a1461834dc0471f4eb7d12b7` | 0x6e8a | 2bpp, 129 tiles (second copy overruns into the glyph table) | added |
| `assets/bank_01/sprite_tiles_7871.2bpp` | $01 | 64 | `c8d7d0ef0eedfa82d2ea1aa592845b9a6d4b02b7` | 0x7871 | 2bpp, 4 tiles | added |
| `assets/bank_01/sprite_tiles_78B1.2bpp` | $01 | 64 | `8d926825774a8e146520ef5eb7b27563d74e3c78` | 0x78b1 | 2bpp, 4 tiles | added |
| `assets/bank_02/burst_tiles.2bpp` | $02 | 528 | `fba343be08aa598ce99e869121f1c92ab2a9f7cf` | 0x9e89 | 2bpp, 33 tiles | added |
| `assets/bank_02/tracker_direction_lookup.bin` | $02 | 2048 | `bc3392db623b91add8fedead651e6343497ca4ed` | 0x9440 | nibble-packed dx/dy -> direction lookup | added |
| `assets/bank_02/indexed_sprite_grid_1.2bpp` | $02 | 640 | `5352a2e8419f9638a4fc9921150a92a7b0821e4a` | 0x8830 | 2bpp, 40 tiles | added |
| `assets/bank_02/unused_indexed_sprite_grid_tiles.2bpp` | $02 | 32 | `24ff2c0caf588ef2c490c56fe21a97c16583ece2` | 0x8ab0 | 2bpp, 2 unused tiles | added |
| `assets/bank_02/indexed_sprite_grid_0.2bpp` | $02 | 640 | `d48c5682c7882d9be5f6891bd69982e63a25c382` | 0x8ad0 | 2bpp, 40 tiles | added |

Removed (every byte now explicit source or a typed asset above):

| Asset | Bytes | SHA-1 | Replacement |
| --- | ---: | --- | --- |
| `assets/bank_01/58DF.bin` | 190 | `a75d94ed60171923b82c48b35755edb6b42b0773` | menu cursor tiles (asset) + tile ids, palette, picture descriptors (source) |
| `assets/bank_01/6E8A.bin` | 2663 | `4de5c9d075f323e234666d2bbaf76a4bb47daa73` | password tiles + two sprite blocks (assets) + glyph/attribute/palette/column tables, unread gaps (source) |
| `assets/bank_01/7D5D.bin` | 675 | `5e124bf19108661ec5b93d94c3ecc1cff71a5734` | `ds` fill + `db BANK(@)` |
| `assets/bank_02/481E.bin` | 1338 | `d025e46aab762189ab4575c3f7bf1740acb8bbe9` | two indexed sprite-grid assets + two unused tiles + same-address bank-$01 pointer residue + alignment padding + `Bank02ObjPalette7` (source) |
| `assets/bank_02/5040.bin` | 3072 | `abd1fa78360b7370b2202b1a5808808c4bfb2ec1` | `TrackerPointerFrames` (source) + `tracker_direction_lookup.bin` |
| `assets/bank_02/5DE0.bin` | 1165 | `5b4fdb833d8b48c8402237dcc03d62558fe04177` | palettes, tile grids, tables (source) + `burst_tiles.2bpp` |
| `assets/bank_02/66DC.bin` | 6436 | `bde6747983763d66d3bfee56cfcac24e6a61eaee` | `ds` fill + `db BANK(@)` |
| `assets/bank_05/40B1.bin` | 591 | `792cffcbd524b60e0d27cf502338bde0cea167d9` | explicit unused bank-$04 spawn-record residue |
| `assets/bank_05/431E.bin` | 226 | `c6a46c321fd468fa326334348905a76eee4a1f51` | explicit unused bank-$04 spawn-record residue |
| `assets/bank_05/452C.bin` | 2420 | `bea028e4bebe0382a2ad4351fc6c8ae1d8486de2` | explicit unused bank-$04 spawn-record residue ($D4 bytes) + `ObjectVelocityTable` and zero gap (source) |
| `assets/bank_05/59E0.bin` | 9760 | `af5cb34c827a99d926d9a72ffd557befe94b08e7` | `src/screen_effect_tables.asm` |
