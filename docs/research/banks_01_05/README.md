# Banks $01-$05: research index

Frozen baselines `ce487700b488c4fddbd45d178b88dc9910adea74` (main pass) and
`e7566ceb909e19f999fc95985a961d748c943fea` (final function pass). Rebuild SHA-1
`5078584e86c0b6f4687c424cc00bbd762ba6573a`.

- [OVERVIEW.md](OVERVIEW.md): accounting, what is understood, what is not
- [BANK01_CONTROL_FLOW.md](BANK01_CONTROL_FLOW.md): menus, options, pause, pickups, scenes, password
- [BANK02_OBJECT_RUNTIME.md](BANK02_OBJECT_RUNTIME.md): interrupt images, tracker, animation frames, boot sequence, burst effect
- [BANK03_SEQUENCE_SEMANTICS.md](BANK03_SEQUENCE_SEMANTICS.md): waypoint sequences, level completion checks
- [BANK04_LEVEL_OBJECTS.md](BANK04_LEVEL_OBJECTS.md): spawn and auxiliary records, respawn queue
- [BANK05_SHARED_TABLES.md](BANK05_SHARED_TABLES.md): orientation, velocity, level and effect tables
- [RAM_RELOCATION_AUDIT.md](RAM_RELOCATION_AUDIT.md): RAM-executed images
- [INDIRECT_CONTROL_FLOW.md](INDIRECT_CONTROL_FLOW.md): every indirect transfer
- [MEMORY_SYMBOLS.md](MEMORY_SYMBOLS.md): RAM symbols
- [ASSET_MANIFEST.md](ASSET_MANIFEST.md): assets
- [RELOCATION_TESTS.md](RELOCATION_TESTS.md): pins and shift tests
- [FINAL_FUNCTIONS.md](FINAL_FUNCTIONS.md): the last 27 bank `$01`/`$03` entries, branch labels, rechecked regions
- [UNRESOLVED.md](UNRESOLVED.md): open questions

Sequence field invariants: `tools/object_sequence_fields.py` (run by `make check`).

Machine-readable reports, checked for freshness by `tools/banks_01_05.py`:
- `reports/banks_01_05_accounting.json`;
- `reports/banks_01_05_labels.json`;
- `reports/banks_01_05_pins.json`;
- `reports/banks_01_05_assets.json`.
