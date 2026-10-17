# Source maturity and naming policy

Byte identity, structural recovery and semantic understanding are separate
milestones.

- **Reconstructed:** the source emits the retail bytes at the correct address.
- **Structured:** boundaries, record widths and references are checked.
- **Named:** behavior, callers or data flow support a descriptive symbol.
- **Understood:** the representation and role are sufficiently established to
  explain and safely edit it.

A source range may be completely reconstructed while still being neutral or
unread. Such ranges remain visible in the range map and status ledger.

Names should state only what the evidence proves. Prefer structural names over
gameplay guesses. Visible text can identify a screen, but visual resemblance
alone cannot identify an object or effect. Original defects are documented and
preserved in the matching source.

Data should be promoted from a binary asset to explicit assembly when doing so
adds checked structure or useful symbolic relationships. Expansion into rows
of unexplained numbers is not an improvement by itself.

Every source change must preserve the exact cartridge hash and pass the
relevant subsystem checks. Moving a label must either relocate every consumer
or trip a documented fail-safe assertion.
