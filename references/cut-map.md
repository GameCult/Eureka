# Cut map shape

A migration keeps two documents in the repo it changes.

- **Target** (`docs/<migration>-target.md`): the ends. It holds the invariants,
  the canonical implementations, what is not a consumer, and the durable design
  truths the migration produces. When the migration closes, the target is
  reconciled with the Body and outlives the map.
- **Cut map** (`docs/<migration>-cut.md`): the means. It is a status header
  followed by one section per cut. It is history once the migration closes.

## Status header

The header owns progress. Self updates it in every landing commit.

```
Status: cut map. Ends are owned by <target>; this document owns the means.

<for each landed cut>
Cut N landed at <repo> <sha range>. Verified: <builds/tests/captures>. Soul
found <defects>, all fixed | recorded. Recorded, not fixed: <items, why>.

Rulings (operator, <date>):
- **QN-M <choice>:** <ruling>. <quote if the wording carries meaning>.
  (Supersedes <earlier ruling>; the old text below is history.)

Open: <operator checks, pending Soul passes, questions>.
Follow-ups outside this migration: <item, file, reason it can wait>.
```

## Per-cut section

```
### Cut N. <name>

- **Repo/branch:** <repo> <branch> from <base>. Depends on <cuts, releases>.
- **First:** <captures or pins taken before any edit>.
- **Deletes first:** <path (lines)>, ...
- **Keeps and moves:** ...
- **Adds:** ...
- **Per-file changes:** <file:line against HEAD sha>: <change>.
- **Authority map:**
  - Owner:
  - Inputs:
  - Outputs:
  - Derived state:
  - Forbidden writers:
  - Shared paths:
  - Deletion line:
- **Verification:**
  - builds: <exact projects>
  - tests: <name> pins <rule>
  - negative: <rg pattern, verified to not collide with legitimate names>
  - operator: <play smoke steps; Studio click-through>
- **Operator questions:** QN-1 <question>. A: ... B: ... **Recommended: A**, because ...
```

## Subtraction ledger

One row per cut: the lines removed, the lines added, and the dependencies,
formats and targets removed or added. Compare the estimate with what landed in
the postmortem.

## Notes from use

- **Test negative greps before publishing them.** `\.loadout\b` matched the
  legitimate schema name `aetheria.loadout`.
- **State the capture method with the capture.** PowerShell `>` writes a BOM and
  CRLF, and the comparison must use the same method on both sides.
- **Prefer normalizers that parse the format.** Ones that split on text leave
  false diffs, as the census normalizer did when it split on `, ` and glued the
  first maker to its kind column.
- **When a later ruling changes a design, sweep the whole map.** Rewrite the header
  and routing tables, and mark the older spec text as history, so no one reads two
  live designs.
