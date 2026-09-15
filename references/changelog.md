# Changelog

Record each change to the skill together with the evidence that motivated it.

## 2026-09-15: Hands brief rules from the Eureka pipeline-state campaign

- **Define every mutation in the report.** Soul could not rerun Hands' Cut 2
  mutations "C1-C5" because the report named them without saying what changed.
- **"Unchanged" is proven against the base commit.** Cut 2 pinned a Mind
  receipt digest captured from the new code. Soul had to rerun the test at the
  base commit to show it matched.
- **Baseline shared build caches by path list.** A Cut 2 Soul pass left about
  401 MB in the shared cargo target that it could not attribute. It had
  recorded only counts, so it did not delete blind.
- **Check that a detached script started.** A Cut 1 mutation script died on a
  PowerShell parse error, and its monitor sat silent for 30 minutes.

## 2026-09-15: renamed to Eureka; postmortem rules folded in

- **Rename.** The operator named the skill-and-MCP form of the pipeline
  **Eureka**. Epiphany stays the name of the running organism, and Eureka keeps
  the faculty vocabulary.
- **Operator observation: typed state.** What makes Epiphany special is that
  findings are stored in typed state that can be queried semantically. Claude
  agents can be given the same state tools. Eureka's likely next step is to
  replace doc, report and memory findings with typed state documents (findings,
  rulings, cuts, Soul verdicts) behind MCP tools.
- **Operator observation: Imagination.** Eureka's Imagination has a more clearly
  defined target-mapping role than Epiphany's. Epiphany may want to adopt it.
- **Epiphany comparison.** A source-grounded model of Epiphany at `71324718` is
  kept as `epiphany-comparison-2026-09-15.md`. It is a dated snapshot, not live
  truth. Epiphany's own `notes/faculty-workflow-lessons-2026-09-04.md:146-176`
  proposes the typed forms of Eureka's habits (Verdict HOLDS/FALSIFIED/UNPROVEN,
  Rulings, a landed-names digest, steward triggers). Start from those schemas
  when Eureka gets typed state.
- **Rules added from the postmortem:**
  - Soul runs before any release or tag.
  - Ask what a domain concept is for before specifying it.
  - Carry order as data, not as scheduling.
  - Reconcile the subtraction ledger at every landing.
  - Count consumers across every project the operator uses, not just one
    runtime.

## 2026-09-15: initial formalization

Extracted from the Aetheria CultCache migration (Cuts 0-10, 2026-09-12..15). The
evidence is `postmortem-cultcache.md` and the Aetheria repo's
`docs/cultcache-migration-cut.md`.

- **Soul is distinct from Imagination.** An operator correction: "Making another
  pass on the cut map is still Imagination."
- **Target shape finish line:** Hands barely reads.
- **Each operator ruling needs its own failing mutation.** In Cut 10, Soul removed
  the availability rule, the price rule and the all-or-nothing fit rule, and all
  15 tests still passed.
- **Don't cap Soul early.** Cuts 6 and 6b each needed four Soul passes.
- **Git and tooling scars:** explicit staging, message files, the 3-tag limit,
  commit-independent byte checks, detached builds, and the process-probe role
  check.
