# Postmortem template

Write the postmortem when the migration closes, from evidence: commits, the cut
map, Soul reports and transcripts. Use an Eyes pass to gather facts first. Report
the delta and the scars, not a victory lap.

```
# <Migration> postmortem

## Summary
What changed, the scale (lines, dependencies, formats), and the state at
writing (landed, and what the operator still owes).

## Scope and invariants
The target in brief, what was excluded, and why the earlier attempt failed if
there was one.

## Timeline
One row per cut: dates, SHA ranges, Soul passes, and the notable finding.

## Structural delta
Estimate against actual, per repo. What was deleted, added and parked.

## What Soul caught
Defects that green tests had passed, grouped by kind (concurrency, wire parity,
lifecycle and globals, untested rulings, split authority, spec errors). Say how
each would have failed.

## Operator corrections
Where the operator corrected the agents' understanding or overturned a plan, and
what context was missing that made the wrong answer look right.

## Incidents
Machine, tooling and process failures, with their cost and the rule each one
produced.

## What worked
Only what should be repeated, stated as practice.

## What to change in the pipeline
Concrete edits to the skill, each with its evidence.

## Open follow-ups
Item, owner, file, and why it can wait.
```
