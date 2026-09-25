# Worked example: Aetheria CultCache migration (2026-09-12..15)

The full postmortem lives with the Body it describes, in
`F:\Projects\Aetheria\docs\cultcache-migration-postmortem.md`. The means and ends
documents sit beside it: `cultcache-migration-cut.md` and
`cultcache-migration-target.md`. Read those when you need detail. This file keeps
only the evidence behind the skill's rules, so that the reasons for the rules
survive.

**Scale:** 114 subagents ran: 50 Hands, 32 Soul, 3 Imagination, 23
Eyes/Explore and 6 Life passes (then called Mind Stewards). Aetheria went
+5.6k / −36.9k lines.

**Soul:** 29 of 32 passes found at least one real defect that Hands' tests
passed, about 75 in all. These included:
- five deadlocks or hangs;
- four lost-write or data-loss paths;
- a wire-parity split (nil map keys that Python rejects);
- semantics copied from docs instead of the compiler (`step` NaN);
- untested operator rulings.

Cut 3 took six passes, and Cuts 6 and 6b took four each. The one cut without a
Soul pass, the Cut 7 release, is where the release defects surfaced late.

**Model budget:** the only Fable agent, the first Imagination pass, hit its limit
before Cut 1. Opus ran everything else, including every Soul pass, and the hit
rate held.

**Operator corrections that became rules:**
- A pass over a plan is Imagination, not Soul.
- Probe every mechanism claim ("the effects you listed don't follow from the
  causes").
- Count capability consumers across projects; atomic commit and compare-exchange
  were nearly cut.
- Delete what only duplicates an owner (the generator).
- Order belongs in data, not in scheduling: tickets were built, deadlocked and
  were deleted.
- Ask what a domain concept is for: loadouts were redefined three times in one
  evening.

**Incidents that became rules:**
- A probe fork-bombed the workstation.
- A message file written by PowerShell 5 carried a BOM.
- A shared message filename collided.
- `git add -A` swept a local file into history.
- A push of more than 3 tags skipped publishing.
- An incremental DLL went stale.
