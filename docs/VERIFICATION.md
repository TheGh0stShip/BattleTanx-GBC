# Verification

## Supported image

| Property | Value |
| --- | --- |
| Title | `BATTLETANX` |
| Game code | `AVNE` |
| Region | USA |
| Size | 1,048,576 bytes |
| SHA-1 | `5078584e86c0b6f4687c424cc00bbd762ba6573a` |
| SHA-256 | `b449bab1b0a422fdb462d0dc5c55fbc8e50d8c18a5e2fd836e7db016ee63aa62` |
| MD5 | `4ca71b12d89a5bcfcc52095081ae9f51` |
| Toolchain | RGBDS 1.0.4 |

See [`REPRODUCTION.md`](REPRODUCTION.md) for a command-by-command clean setup,
including complete asset regeneration from a legally obtained supported image.
See [`COMPLETENESS.md`](COMPLETENESS.md) for the limits of the 100% figure.

## Gates

`make verify-source` requires no retail cartridge. It assembles the committed
source and assets, checks semantic naming, creates the objdiff v2 report, and
runs repository-safety checks.

`make check` additionally requires the supported cartridge as `baserom.gbc`.
It performs the byte comparison and then runs:

- whole-project structural checks and asset-slice verification;
- graphics, scene, level, screen and object-bank lossless round trips;
- relocation audits and 30 source-shift cases;
- whole-ROM gap/overlap accounting;
- operand and indirect-control-flow audits;
- completion and semantic invariants with deliberate negative mutations;
- the 288-entry source-name check.

The expected reconstruction report is:

| Category | Matched | Total |
| --- | ---: | ---: |
| Program and RAM-executed code | 39,359 | 39,359 |
| Data, assets, padding and markers | 1,009,217 | 1,009,217 |
| Code ranges | 1,094 | 1,094 |
| ROM banks | 64 | 64 |

These are reconstruction figures. Semantic status is tracked separately in
`docs/STATUS.md`; padding and unknown data are not described as understood.

## Published report

`.github/workflows/bytematch-report.yml` builds on the default branch and
uploads `report.json` as the `USA_report` artifact. The file follows objdiff v2
and separates code, data and padding categories. Every range is checked against
the freshly linked image before it is reported.
