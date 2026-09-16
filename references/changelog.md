# Changelog

Record each change to the skill together with the evidence that motivated it.

## 2026-09-16: record the gap, and absence is the hardest claim

Evidence: ghostlight-77's requirements message to the Eureka pipeline-state
campaign, drawn from Ghostlight `docs/architecture/ghostlight-library-extraction-cut.md`
and its postmortem. Both rules come from the same run as the entry below.

- **Record the substrate you needed and did not have.** That campaign hit the
  missing typed-state primitive six separate ways — supersession tracked in
  "(supersedes …)" prose and fixed by substring surgery, an "Open:" question
  line hand-edited about eight times, three ad-hoc finding namespaces, verdicts
  linked to nothing, a subtraction ledger reconciled only at close-out where it
  showed a +65 → +210 overrun, and a status header rewritten by hand at every
  landing. Each workaround worked, so each requirement nearly evaporated. The
  agent named this itself: the failure was working around the gap silently
  rather than flagging it while hitting it. A run that hits one gap six times is
  the best requirements evidence a design will ever get, and it survives only if
  someone writes it down while it hurts. Working around the gap is still
  correct — doctrine says do not wait on a service that does not exist — but
  leave the evidence.
- **Proving something is gone is the claim most likely to be wrong.** A Mind
  Steward reported a stale phrase retired because a line break had split it from
  its grep. The phrase was still there, still steering. A verification that
  cannot see its own target reports a clean pass, which is worse than no
  verification: it closes the question. Prose reflows, so an exact search over
  it is a tripwire with the same limits as any other text scanner — the
  scanner rule below is not only about code.

## 2026-09-16: sealing, forgeries, scanners and proportion, from Ghostlight L0

Evidence: Ghostlight `docs/architecture/ghostlight-library-extraction-postmortem.md`
and its cut map.

- **Soul attacks constructibility, not names.** Ruling Q1-4 said sealed
  constructors must be unreachable. Ten compile_fail doc-tests passed while
  every public ID type derived `Deserialize`, so an external crate built any of
  them from JSON; an ID-minting `Default` impl left all ten green. It was found
  only because Self added the serde route to the Soul brief by hand. On stable
  rustc the compile_fail error codes are not enforced either.
- **Rejection tests need realistic forgeries.** Short fake digests passed
  against kernels comparing only length, a prefix, all but the last character,
  case-insensitively, or only the hex after the label. Five mutants survived
  across two Soul passes.
- **Text scanners are tripwires.** Every one written in the campaign lost to a
  short evasion: a single-minter count to an alias, a subdirectory, a type
  alias and a function value; a deploy wiring test to a two-line deletion that
  reattached the pinned line to the wrong container, and its fix to `if false`
  around exact lines. Prefer a semantic tool, or state the limits.
- **Default proportionate forks.** Asked how much the single-minter enforcement
  question mattered, the operator said not at all. A fork that guards only
  against the project's own code is a default plus a recorded follow-up.
- **Hands brief additions:** wait for long jobs instead of reporting a to-do
  list (one Hands agent did); restore mutations without `git checkout` (one
  run was invalidated that way); measure warnings from forced rebuilds (a
  cached build reported zero).

## 2026-09-16: subtraction rules, from the Eureka campaign's own cuts

- **A deletion can take a live rule's only test with it.** Cut 4 deleted a store
  module; the epoch guard that survived in another file then passed a `if false`
  mutation, and nothing could construct the state needed to reach it. The fix
  was to delete the unreachable rule too, not to write a test for state nothing
  can build.
- **A mutation that never applied is not a passing mutation.** A multi-line
  anchor matched nothing on a CRLF working tree. Scripts must fail loudly on a
  stale anchor, and should also assert the anchor matches exactly once, since a
  multi-site replace can read as "killed" when its test failed for another
  reason.
  - **Correction, same day.** Self first recorded this as "one mutation reported
    a verdict it never earned". Soul checked the committed history: the script
    already threw on a missing anchor, the affected mutation existed only in
    Hands' working copy, and every committed verdict was real. The rule stands;
    the incident was narrower than first written.

## 2026-09-16: an instance owns its mind, and a service owns the state

Operator correction, mid-campaign, after three Soul passes spent propping up a
repo-owned store: "I think someone needs to own Epiphany/Eureka state. Each
store should be canonical to one instance, the store is that instance's mind,
and that instance can be assigned stewardship over multiple repos."

- **The lesson for this skill:** when a design needs escalating machinery to
  hold together (a per-clone lease, git-directory resolution, committed
  attribute checks, a merge tool), the missing piece is usually an owner, not
  another guard. Soul kept confirming the guards were weak; the guards were the
  symptom.
- Mind state does not belong in version control. Git offers branches, merges and
  history rewriting; a mind wants one owner and an append-only record.
- Eureka's typed state will live in a memory organ service (Huginn) that owns
  each instance's mind, depends on Qdrant directly, and refuses loudly when
  unreachable rather than letting a second writer exist.

## 2026-09-15: the operator channel is the session

Operator ruling. Spec iteration proved to be the load-bearing part of a Eureka
run, so the question path matters as much as the cut loop.

- Eureka has no Persona. Self is the operator surface.
- Blocking questions may be pushed through any notification MCP the user
  configures. Eureka owns no transport, so other people can swap in their own.
- Answering over a chat channel is a later campaign; it needs identity binding
  before a reply can become a ruling.
- The operator's framing: Epiphany gives each repo an identity, memories and a
  Persona to talk to; Eureka is "the cut-down Claude-native version anyone can
  use".

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
