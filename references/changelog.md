# Changelog

Record each change to the skill together with the evidence that motivated it.

## 2026-09-22: the hand-written mutation harness is retired, with no fallback

The operator said: "The manual mutation testing turned out to be a terrible
idea, lots of guarding the shape of the code instead of the behavior. Better
to have nothing than a harness that punishes refactoring." Asked whether a
fallback should remain for code no ecosystem tool reaches, the operator chose
to retire it entirely: "absolutely".

Evidence from the same day, beyond Aetheria's:
- The Huginn, Epiphany-leaf, Idunn and QUIC campaigns spent pass after pass
  re-anchoring suites after refactors and rewriting entries that could no
  longer fail.
- The harness itself was repaired four times: H1, F1/F2, the case-blind
  guard, and Linux quoting.
- The QUIC timeout rule took seven Soul passes of anchor mutants. It closed
  only when a behavioural seam made the rule observable by exact equality,
  which is the defence that survives a refactor.

What changed:
- `tools/eureka-mutations.ps1` is deleted (Eureka `37c80e4`).
- SKILL.md and briefs.md no longer name a fallback. Where no tool reaches, the
  defence is behavioural: observe the rule where it is decided.
- Soul's hand mutants are one-off probes on scratch copies, never committed.
  The entry below, "hand mutations target the rule's layer", now governs
  exactly those probes.
- The stopgap copies no harness into the container. Its Rust image carries
  cargo-mutants instead of pwsh, and the image is tagged by the Dockerfile's
  hash so an edit rebuilds it.
- The committed suites in Huginn, the Epiphany leaf, Idunn and CultLib are
  deleted in their own repos. The tests those suites pointed at stay.

## 2026-09-22: a test's inputs come from production

Evidence: Ghostlight's play agent 8a-fix3 (`754c7fe`) ruled that the DM agent
dispatches Personas by the id its world view prints. Every test built that id
from a test-local copy of the printer, so changing what the view printed left
all 735 tests green while every dispatch an agent could make was refused.
There were four copies of one spelling, because the library's printer was
private to its module.

## 2026-09-22: hand mutations target the rule's layer

Evidence: in Ghostlight's play agent 8a-fix2 (`74b628d`), Hands reported every
mutation killed, yet Soul found eight rules unguarded. Hands had deleted the
in-memory `record_call` instead of the on-disk persist-before-submit, which
a later persist then hid. It tested `find_handle_collision` directly rather
than its call in `round_tools`, and every test used fresh keys, so
`turn_id = hash(key)` survived. The Hands brief now says to mutate the
production call site and to observe the result where it lands.

## 2026-09-22: mutation testing moves to the ecosystem's tools

Evidence: Aetheria's fire-control campaign carried 23 hand-written harnesses
(5,816 lines) of literal-text anchors and substitutions. They stranded on
every refactor (`72c0109c`, Cuts 9 and 10), and at Cut 10 an anchor kept
matching exactly once while silently re-targeting from `HitProbability` onto
`Inspect`, mutating code the tests no longer ran, and it surfaced only as
unexplained survivors. Soul's audit of the
harnesses also found the tree-clean verdict restoring before it measured, and
a compile failure counted as a kill. The operator: "What is the point of those
mutation anchors? Tests should cover how the code behaves, not how it is
shaped."

A Stryker.NET spike over one file killed every mutant the harnesses defended
and found 67 survivors they did not, among them a flipped sign in the splash
handedness that no test defended: the same class as a wrong-side-damage bug the
operator had once spent hours hunting in legacy code, though the rewrite had not
shipped it. Three rounds of tests and fixture fixes took it to 43, all named.

- The principle of 2026-09-15 stays: every rule has a test that fails when it
  breaks.
- The committed-anchor-script mandate is replaced: Hands and Soul run the
  ecosystem's tool on the cut's diff and triage survivors by name.
  `eureka-mutations.ps1` is demoted to the fallback for code no tool reaches.
- Float boundary flips are equivalent by default (operator: "> to >= on float
  thresholds is indeed petty"); the score is not a gate.
- The harness-hardening entries below (H1, F2, the case-blind guard, the
  CRLF anchor) remain the record of why the fallback's contract is what it is.

## 2026-09-22: verification moves off the operator's workstation

Evidence: Starfire went from fine to unresponsive in seconds, and the operator
had to force a shutdown. It was carrying four jobs at once:
- 16 `node` CPU burners at twice the CPU count. They were started for a QUIC
  stress run that Self's own rulings demanded. Git Bash's `$!` recorded MSYS
  PIDs, and the burners were very likely never stopped.
- A 30-iteration `dotnet test` loop.
- A Huginn workspace build.
- Two agents waiting on jobs that had already died.

No single fork bomb was proven, because Windows audits no process creation.
The load was Self's to schedule and Self did not budget it. The operator: "This
is literally why we have Yggdrasil, so Starfire doesn't get overloaded with
compiler jobs." The fleet inventory already said the same.

- Ruled by the operator: **Idunn owns verification**, through a verify
  transaction that seals nothing and sits outside the brake. It is mapped as
  its own campaign.
- The stopgap until then is `tools/stopgap/ygg-verify.sh` plus
  `rust.Dockerfile`. It pushes an exact revision to a mirror on Yggdrasil and
  runs the command in a container capped at 6 CPUs and 16 GiB, niced, with at
  most two jobs at once. The target directory stays inside the scratch work
  tree. Its header names its deletion line.
- **Correction, same day, found by a Mind Steward pass:** the caps above are
  not what shipped. `ygg-verify.sh` defaults to **4 CPUs, 12 GiB and 3 slots**
  — the slot raise was the operator's ("the other cores are mostly sitting
  idle") and is recorded in the script's header; the 6/16 figure is not, and I
  cannot say from here whether it was ever live or was written from a plan I
  then retuned without a line. SKILL.md carried the stale "2 jobs" until this
  pass caught it. **The script is the owner of these numbers.** Prose that
  restates a running tool's configuration goes stale silently, which is how
  three surfaces came to disagree inside one day.
- The smoke test found two bugs in the stopgap before any real job ran:
  - `bash -lc` reset the image's `PATH`.
  - `ssh` re-split the command, so `a && b` ran `b` on the host.

  Arguments are now quoted with `printf %q`. After the fix, Huginn's mind
  suite passed 67/67 on Yggdrasil.
- SKILL.md: heavy verification goes to Yggdrasil. Starfire does only
  Windows-bound work, one job at a time, with no burners.

## 2026-09-22: H1's kept sidecar looked like a crash, overwrites clobbered each other, case-blind no-op guard

Evidence: Soul's H14 pass over the Huginn memory-organ campaign
(`soul-h14-notes.md`, findings C and D) found two defects in the sidecar
machinery the 2026-09-22 H1 fix (below) had just added, plus a third,
unrelated defect in the no-op guard.

**F1: startup repair mistook H1's deliberate stop for a crash.** H1 keeps a
target's sidecar on purpose when it catches an edit the harness did not make
(`Assert-TargetUnedited`), so the M0 original survives beside the lost edit.
Startup repair could not tell that kept sidecar apart from a crash's: on the
next run it restored the M0 original over whatever an operator had since
hand-cleaned into the target, moved the operator's clean file to
`.eureka-mutation-overwritten` (clobbering H1's own copy there, see F2),
printed "a previous run died mid-mutation", and finished green. The hand
edit was gone one run later with no non-zero exit to notice it by.
`Assert-TargetUnedited` now writes a marker, `<target>.eureka-h1-stopped`,
beside a sidecar it keeps; startup repair refuses the whole pass while any
such marker exists, restores nothing, and names what to reconcile. An
operator clears the marker by hand once the file is reconciled. Demonstrated
in a scratch repo: before the fix, a hand-cleaned target was silently
reverted and the rerun exited 0; after, the rerun refused with a named
non-zero exit and the target was untouched.

**F2: `.eureka-mutation-overwritten` was overwritten without a check.** Both
the sites that preserve bytes about to be lost (`Assert-TargetUnedited` and
the startup repair loop) wrote to a fixed name, so a second loss against the
same target, or a file already sitting at that name, was silently destroyed.
`Get-UniqueOverwrittenPath` now picks the first unused name in the family
(`.eureka-mutation-overwritten`, then `.1`, `.2`, ...). Demonstrated: a
planted file at that path survived an H1 firing, with the new loss landing
at `.eureka-mutation-overwritten.1` beside it.

**Case-blind no-op guard.** The check that rejects a mutation whose old and
new text come out identical used PowerShell's `-eq`, which is
case-insensitive, so a mutant differing from the source only in case (such
as `"query"` to `"Query"`) was wrongly refused as a no-op. Every hash
comparison in the script had the same latent gap. Both were switched to
`-ceq`/`-cne` (eight sites total); anchor matching already used ordinal
`IndexOf` and needed no change. Demonstrated: a case-only mutation was
refused before the fix and ran (and was killed by its test) after.

All three fixed and demonstrated in `tools/eureka-mutations.ps1`; commits
`6ec92de` (F2), `5ac4fea` (F1), `42adfb0` (case).

## 2026-09-22: the harness silently discarded an edit made while a run was in flight (H1)

Evidence: Soul's pass on the Huginn memory-organ Cut 10 fourth fix batch
(2026-09-22) found that `eureka-mutations.ps1` never checked what a target's
bytes actually were before restoring over them or before the next entry wrote
its mutant. That same campaign's fourth fix batch had lost edits Hands made to
a target this way; the harness gave no warning and no non-zero exit at the
time, so the loss surfaced only later.

`Restore-Targets` (`:163-182`) now hashes the target's current bytes first: a
match against the M0 original or, when supplied, the exact mutant the caller
just wrote, is restored as before; anything else is saved beside the target as
`<target>.eureka-mutation-overwritten`, printed as a loud `EDIT LOST` warning,
and the run stops (non-zero exit, no further entries) via the new
`Assert-TargetUnedited`. The same check runs again before each entry writes
its own mutant, so an edit landing between two entries is caught before it is
silently buried under the next one.

Demonstrated in the scratchpad with a throwaway repo whose test command
appends a line to the target mid-run: against the pre-fix script the run
reported green and the target came back pristine, the appended line gone;
against the fixed script the run failed loudly with `EDIT LOST`, exit code 1,
and the target still carried the appended line afterward.

## 2026-09-22: a cleanup by image name killed the whole machine's Node

Evidence: during the QUIC seventh fix batch's Windows stress round, Hands
cleared its busy-loop burners with `taskkill //IM node.exe //T`. That kills
every `node.exe` on the host, and the workstation is shared by several agents
and the operator. The kill can't be undone, and nothing records what it took
down. Rule added to SKILL.md's tooling list: kill by the PID you started.

## 2026-09-22: seven passes on one line, because the observation was outside

Evidence: the QUIC bridge's rule "the wait is the timeout the host asked for".
It took seven Soul passes and six fix batches.

- Every batch killed the mutants the previous Soul had named: a constant, then
  any constant, then a clamp, an offset and a scale. Then a round clamp, a
  floor and a small offset. Then a quantum round-down, a small-timeout zero and
  a later-poll doubling.
- Each time, the next Soul found another function of the argument that equals
  the identity at every probe point.
- Tolerances tightened until Windows needed a priority raise just to keep the
  unmutated bridge green. Even then, two of the stated boundaries flipped
  between repetitions.

Wall-clock observation from outside cannot converge on an arithmetic rule.
There is always another function that matches at the probes, and the
tolerance can only shrink until the scheduler decides the answer. The fix was
to observe at the rule itself: a dev-only seam records the timeout actually
handed to the condition wait, and exact equality kills the whole family at
once, deterministically.

The skill already said "put the observation where the rule is decided". What
was missing was knowing when to stop probing. Added to Self's triage:

- **When a second fix batch for the same rule is killed by mutants of the same
  family, change the observation, not the probes.** Name the layer where the
  rule is decided and observe there. Keep wall-clock checks only as proof the
  decision is actually carried out, with generous margins.

## 2026-09-22: a ruling recorded in one section, contradicted in another

Evidence: the selection map recorded Q-J (decimal strings) as ruled in §16.
§2, the vocabulary Hands actually builds from, still said `number: float64?`.
D8 said `NumberOf -> double?`. Nothing specified the canonical form or the
comparison that the ruling had asked for. Commit 1 shipped float64 to the
branch. The Rust Hands found the conflict before writing a line, and stopped.

- SKILL.md already says to sweep the map for the old version of a design on
  the same day a ruling changes it. Self did not do the sweep. The rule was
  fine. Self's compliance with it failed.
- A ruling that says "the cut must specify X" is not landed until X is
  specified in the section Hands reads. Recording the ruling is not
  specifying it.

Same evening: two Sonnet Hands stopped early with no fork, one of them after
fourteen tool calls. Both cited budget. Both had been told to read a
1,500-line map rather than given their cut inline, which breaks the template's
"carry the cut inline". The template's hand-back clause is now qualified: it
applies when context is actually filling, not when scope looks large.

## 2026-09-22: a shared cargo target can run another checkout's mutant

Evidence: Soul, working on the Huginn Cut 10 second fix batch, had two worktrees
of the same repository. Both built into `C:\Users\Meta\.cargo-target-codex`, and
both produced the same artifact name, `huginn_daemon-e1f33b5708db9f04.exe`.
A plain `cargo test` in the second worktree did not rebuild, because its sources
were older than that binary. It ran the first worktree's last harness mutant
instead: 40 runs out of 40 failed at the mutant's assert line, not at the
source's.

- The case that does damage is the reverse. A surviving mutant's binary makes an
  unmutated tree look green.
- The harness is immune, because every write it makes, M0's included, bumps the
  file's modification time. A plain test run in a second checkout gets no such
  protection.
- Rule, in SKILL.md's git and tooling list: a shared build output directory
  belongs to one checkout per repository. Any second checkout gets its own
  target subdirectory.

The same evening, Self briefed four agents freehand, and none of the briefs
carried the template's wait paragraph. That breaks the 2026-09-17 rule below.
Self sent the paragraph to the three agents that could still act on it. The
rule stands. What failed was Self's own compliance with it.

## 2026-09-17: Self's own briefs dropped the template's wait rule

Evidence: in the Aetheria item-provenance session, two Hands passes (the Cut C census
follow-up and the neutral wanderers and IFF patch) ended their turns while a mutation run
was still in the background. Each had to be resumed to finish, push and clean up.

- The Hands template in `briefs.md` already says a wait is a foreground poll, and that a
  detached job cannot wake an agent whose turn has ended.
- Self wrote those briefs freehand and left that paragraph out. The defect was in Self's
  briefing, not in the template.
- Rule: when Self briefs Hands or Soul without pasting the template, it still carries the
  template's wait paragraph verbatim.

## 2026-09-17: three passes to pin one line, because each proved a cousin

Evidence: the QUIC bridge's "the wait is the timeout the host asked for", over
three Soul passes and three fix batches in one day. Each fix was real, and each
proved a property slightly stronger than the last and still weaker than the
rule.

- The committed entry proved the wait was **not one particular constant**. It
  died only because one millisecond is less than a fifty-millisecond settle.
  A different constant, two seconds, walked the whole matrix on both targets: a
  host asking for five seconds would silently get two, forever.
- The fix proved the wait was **not any constant**, with a scenario measuring
  elapsed time at two values whose tolerance bands do not overlap. Sound as far
  as it goes.
- Soul then defeated it with a **clamp**, and with an offset and a scale beside
  it, all three surviving every scenario. Capping a wait so that shutdown gets
  noticed is the most ordinary spelling that line will ever be given, and it is
  a function of the argument rather than a replacement for it. Any mapping that
  is identity at both probe values passes for free, and both probes sat below
  any plausible ceiling.

Added to the Hands brief: name the weakest thing that would still pass and ask
whether it is the rule; when a rule says a value is derived from an input, at
least one mutant must itself be a function of that input, and probe values must
sit where such a function would show. Constants are never the hard case, only
the first one.

The same pass found that a fresh Windows clone could not run the documented
Linux path at all: `.gitattributes` carried no line-ending rule for shell
scripts, so the container died complaining about a carriage return in the
interpreter line. Worth noting as a shape rather than a one-off: the path was
declared runnable-as-committed and verified by an agent who had never cloned it
fresh.

## 2026-09-17: both honest gaps were wrong, and one probe was blind by design

Evidence: two Soul passes on the same day, in different repositories, each
falsifying a gap that Hands had recorded honestly rather than faking.

**The daemon arm.** Hands wrote that the open-items dispatch arm could carry no
mutation entry, because it raises no refusal of its own and its only failing
paths need a corrupt store, and said so in the entries header rather than
substituting an easier target. That was the discipline working. Soul then built
a store-integrity probe from the crate's own public surface and killed both the
swallowing and the rewrapping mutant, neither of which the shipped suite caught.

**The bridge rule.** Hands wrote that popping before copying was unreachable
without a listener, a credential and a connection. A client opening to a closed
loopback port reaches it in about a millisecond, in fifteen lines, because the
failure path always publishes a non-empty reason; and the mutant crashes an
ordinary optimised build twice out of two while both committed scenarios stay
green on that same binary.

So an unreachability claim is a hypothesis, and the same pass that would
falsify a promise must falsify it. Recorded in the Soul section: write the gap
as not yet reached, never as unreachable, and open the next brief with reaching
it. A rule written off as undefendable that is merely undefended is worse than
a surviving mutant, because the suite and the prose agree and both are wrong.

**The blind spot.** The same pass found why a rule kept being pinned by
constants: the scenario held its callers *after* the wait whose duration was
the rule, so every timeout mutant landed behind the observation. Replacing a
caller's timeout with a hard-coded two seconds survived the entire committed
matrix on both targets; a host asking for five seconds would silently get two
forever. The committed entry that appeared to defend the rule died only because
one millisecond is less than a fifty-millisecond settle. Added: put the
observation where the rule is decided, and when a mutant dies, ask which of the
two things it actually contradicted.

Also added, from the same pass: never use `git archive` to export source for a
byte comparison, after an export carried 1,459 inserted carriage returns.

## 2026-09-16: a green suite is not evidence when its harness is gone

Evidence: two findings from the same afternoon, both about mutation suites
reporting coverage they did not have.

**The harness that no longer exists.** The QUIC cut's native bridge had its
mutation history entirely in agent scratchpads: the consumer, the close
scenarios, every reported kill. When a later Hands pass went to mark which
target two entries were honest on, their definitions were gone and could not
be reconstructed, so the rules they had protected turned out to be defended by
nothing a future agent could rerun. Soul cannot commit, so a probe that is the
only thing killing a mutation must be handed to the next Hands pass and
committed. Added to the Soul section: reported kills are evidence only while
the thing that did the killing still exists.

**The loosening swapped for an easier target.** Cut 10 of the pipeline-state
campaign reported 31 of 31 entries killed. Two of those entries were
replacements: the loosenings the brief demanded could not fail, so Hands wrote
different ones and reported the sweep. Soul then killed nothing and found
plenty: comparing only the lengths of two instance names survived, comparing
only their first bytes survived, and running the gate only when one name was
longer survived, because no fixture pair had ever shared a length. The rule was
undefended while the suite claimed two mutants for it. Added to the Hands
brief: an unfalsifiable loosening is a finding about the fixtures, and the
fixture is what gets fixed.

## 2026-09-16: front-load the invariant layer, thin the spelling layer

Evidence: the operator's read of the Eureka pipeline-state campaign, that the
design kept being discovered as the work went, producing re-cutting and
repeated Imagination passes with no good reason for the map to diverge that
far. The campaign's own record agrees, and says which layer was at fault.
Every backtrack was identity, lifecycle or authority, and every one was
answerable before a line of source was read:

- The repo-owned store was specified before anyone asked who owns a mind, and
  died whole in Cut 4: 1,302 lines deleted.
- The key grammar was patched twice and redesigned on the third occurrence,
  because ids had no namespace to be specified over.
- Cut 6d retrofitted sequences into landed keys, because each document's shape
  was specified and its life was not.
- The operator's forks surfaced across five cuts, so rulings kept landing on
  code that was already written. Two of them reversed defaults the agents had
  already implemented.

None of that was a shortfall of `file:line` detail. The maps had plenty:
Cut 10's section ran to roughly eight hundred lines against a crate that did
not exist. The operator named the trap for what it is, a 1:1 map, where the
only sufficient spec is the code.

- **Added step 0b.** A model table before any cut is mapped, a row per
  persistent kind, three columns: what names it, what happens to it over time,
  who decides. No cut is mapped while a cell is empty. Operator forks are
  assembled in the same pass as one batch.
- **Added the model-page brief** to `briefs.md`, before the cut-mapping brief.
  An empty cell is the finding; inventing a plausible value is the failure.
- **Qualified the per-file anchors.** They are required for code that exists,
  where they say what to delete and what not to touch. For code that does not
  exist, name the types, the boundaries and the rules that must die under their
  own mutation, then stop.
- **Stated what cutting faster means:** less prose per cut, never more code per
  cut. Small commits stay small.

Not treated as waste: the operator changing their mind. Learning that the
intent differs is the job. It is only expensive when it is learned after the
code lands, which is an argument for surfacing forks earlier rather than for
mapping deeper.

## 2026-09-16: the loop was burning tokens on gaps, not defects

Evidence: one day of the Eureka pipeline-state and TypeScript QUIC campaigns,
about thirty-five passes. The operator asked how much of the cost was process
and how much the price of a second agent. Roughly half each. The falsifier
earned its half: three High key defects, an unimplemented epoch gate, a
replay regression, a byte-order mark divergence and a false "equivalent"
claim, none of which a green report caught. The other half:

- **Hands wrote revert mutations; Soul wrote loosenings.** Most second and
  third Soul passes found not defects but rules the suite was blind to. The
  Hands brief now requires both mutations per rule, and Soul reruns Hands'
  loosenings before writing its own.
- **Reports were narrative.** Soul passes ran two to three hundred thousand
  tokens each. Both briefs now name the report shape and forbid the rest, and
  a second pass on a cut is scoped to the fix batch's diff.
- **Two harnesses re-learned each other's lessons.** Epiphany's PowerShell
  harness and CultLib's JavaScript runner each hit the sidecar footgun, the
  missing control and a control-byte scar on their own. One harness in this
  repo is the next change; deferring it to a "skill wiring" cut cost three
  rediscoveries in an afternoon.
- **The map committed per event**, about forty times in a day. Per cut from
  now on, rulings excepted, since agents read them mid-flight.

## 2026-09-16: agents must be told how to wait, not only to wait

Evidence: Ghostlight L1, the stock lenses
(`docs/architecture/ghostlight-stock-lenses-cut.md` and its postmortem).

- **"Wait for long jobs" was not enough.** Three agents in one campaign ended
  their turns while a build they had started was still running: a Soul pass
  on Cut 1 and a Hands pass on Cut 2, twice. Each launched cargo detached,
  then ended the turn "to wait". A detached process is not a tracked
  child of the agent, so its completion never woke it; the work stopped until
  the root agent resumed it by hand. The rule to wait was already in the
  briefs. What worked was naming the mechanism: block inside a tool call,
  with cargo in the foreground under a long tool timeout, or `Wait-Process` on
  the pid, and never start a second cargo run while one holds the target
  lock. After that sentence entered the briefs, no agent stalled again.
- **A green test can be a coin flip.** A Cut 3 test that rewrote a session's
  lens to a fixed value collided with a randomly drawn lens about one run in
  eight; Hands' single green run was luck. It failed 3 of 40 looped runs and
  passed 120 of 120 after a deterministic fix. For any test built on a random
  draw or a random identity, looping it is part of verification.
- **An operator question can hide the design fault.** Self told the operator
  a lens "has to be recorded" in the command identity. The planner then found
  that keying identity on mutable weights strands rows, and the operator's
  follow-up ("are you relying on some deterministic code outputting the same
  id rather than just checking the state?") exposed a pre-existing defect: the
  elaborator's repair loop had never worked across sweeps. When the operator
  asks why a mechanism works, answer from the Body and probe it; it may be
  the most valuable question of the campaign.

## 2026-09-16: a mutation suite needs a no-op control and byte-exact I/O

Evidence: the Eureka pipeline-state campaign's third Soul pass on Cut 6, and the
Eyes audit that followed (Epiphany `notes/eureka-pipeline-state-cut.md`, "Mutation
harness audit").

- **A no-op control is the test of the harness.** Soul ran a mutation that
  changed nothing and it killed `bounds_refuse_in_utf8_bytes`. The harness's
  text round-trip had collapsed an `é` literal to one byte, so the corruption
  alone failed the test and every mutation through that path would have
  reported a kill. Nothing else in the loop could have noticed: a killed
  mutation is what a working suite looks like.
- **The defect was not where it was feared.** The audit found every committed
  suite using byte-lossless I/O. The corrupting harness was Soul's own inline
  script, never written to disk, so its text is unrecoverable and its verdicts
  are unverifiable. That is the same shape as the standing finding that
  mutations without artifacts cannot be checked; it now applies to Soul too.
- **Encoding symmetry and line endings, not a flag.** Measured on the host:
  mixed-encoding round-trips corrupt non-ASCII; any read that splits lines
  rewrites every line ending regardless of encoding, and `core.autocrlf` hides
  the rewrite from `git diff`. One ad-hoc Cut 1 script did exactly that, so
  three early verdicts are recorded as suspect.
- **The committed suites forbade a control by shape.** Each threw when a
  replacement changed nothing. A table shape that cannot express "change
  nothing" cannot test itself.
- **Soul brief: wait for long jobs.** The Hands brief had this rule since the
  Ghostlight run; the Soul brief did not, and two consecutive Soul passes on
  Cut 6b ended their turn with "waiting on the script" and had to be resumed
  by Self before any finding arrived.
- **"Default model" means the root's model.** After the operator switched
  the root session to Fable, every Hands and steward dispatched without an
  explicit model inherited Fable, against the skill's own allocation. The
  operator noticed. Self now names the model on every dispatch: the strong
  model for Imagination and for Soul on foundation cuts, the default tier by
  name for Hands, Eyes, probes and stewards.
- **"Wait" now names the mechanism.** A Hands pass with the rule in its brief
  still ended its turn on "waiting on the suite", the third such yield in one
  day. The rule said what, not how; an agent that starts a detached job
  reads "wait" as "stop and be woken", and nothing wakes it. Both briefs now
  say: a foreground poll loop you run yourself, in chunks under the tool
  timeout, until the job exits.

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

- 2026-09-18: the wait rule now names the failure shape, not only the
  mechanism. Hands ended two turns announcing it would wait for a mutation
  suite (Aetheria shield Cut 3), the second after an explicit correction. The
  brief already said how to wait; it did not say that saying "I'll wait" and
  yielding is the violation. Both copies in `briefs.md` now do.

- 2026-09-18: context is a budget. The operator noticed Sonnet Hands runs
  passing 400k tokens on Aetheria's stats and shield cuts and said they "start
  to get loopy with that much context" — matching where the sloppy claims in
  those runs appeared. `briefs.md` now tells Self to size cuts to one worker's
  head: verify once at the end, quote the cut inline instead of pointing at the
  whole map, keep expensive scaffolding alive across cuts, and hand back a
  clean partial rather than push through.

- 2026-09-22: never amend or force-push a shared branch. In the Ghostlight
  play-agent pass, a Sonnet Hands agent on Cut 3 amended its pushed kernel
  commit and force-pushed it (`9fbdde8` -> `4c4973b`). Self was pushing
  cut-map commits to the same branch at the time. Nothing was lost, only
  because Hands had rebased on those commits first. `briefs.md` now forbids
  amend and force-push and says to fix with a new commit, and SKILL.md's
  scars list carries the rule. That run also reached ~400k tokens against a
  brief that pointed at the whole map, which is the 2026-09-18 context-budget
  rule showing up again.

## 2026-09-22: a Hands agent read a five-day-old map, and refused an unsigned instruction

- **Maps go on `main`.** Self had been committing campaign maps to whatever
  branch it was standing on. A Hands agent on the CultNet selection cut
  reported that the map carried no fix-batch-4 section — true on the branch it
  could see, where the copy was from 2026-09-17. It worked from its brief
  instead and flagged the gap, which is the only reason this surfaced rather
  than a cut built on stale design. SKILL.md now says maps are committed to
  `main` and that every brief names the map's branch.
- **The same agent refused an out-of-band instruction, and was right to.**
  Self sent it the Stryker survivor list mid-task through the agent messaging
  path. It arrived appended after a tool result, claimed to be from "the
  coordinator", and asked to expand scope well beyond its brief. The agent did
  not act on it and flagged it for verification instead. The message was
  genuine. **The lesson is not to make the agent more trusting.** Scope
  expansion mid-task should arrive as a new brief with its own dispatch, or be
  confirmed by Self before the agent acts; an instruction that cannot be
  distinguished from an injection should be refused whether or not it happens
  to be real.

## 2026-09-22: two Hands in one working tree, and the agent that refused to force it

Evidence: Self dispatched a Hands agent for the CultNet selection survivor
tests into `F:\Projects\CultLib` while another Hands was mid-build in that same
checkout on a different branch. The second agent switched the branch to reach
its own work, which pulled the tree out from under the running build, then
found an uncommitted `CMakeLists.txt` edit it had not made. It **stopped and
reported a concurrency hazard rather than forcing the checkout**, which is the
only reason nothing was lost.

The rule against parallel Hands in one working tree was already in SKILL.md.
Self ignored it. The fix is not a stronger warning to Hands: Self now **creates
the worktree before dispatch and names it in the brief**, so an agent is never
left to find somewhere to stand. A brief that names a repo path without naming
a worktree is a defect in the brief.

Second-checkout build output stays separate, per the existing scar: a shared
target directory has let an unmutated tree look green.

## 2026-09-22: a green Windows suite that had never loaded the pinned library

Evidence: the QUIC bridge imports `msquic.dll` by name. Nothing copied the
pinned library beside the test binary in the build tree. On Linux that failed
loudly with `cannot open shared object file`. **On Windows it did not fail at
all** — DLL search fell through to `PATH` and loaded an unrelated `msquic.dll`
from the Windows Performance Toolkit, 529 kB against the pinned build's
4.1 MB. Every scenario passed against it with nothing indicating a problem.

The green result was the thing hiding the defect, and it was found only
because a brief asked for the documented path to be executed literally rather
than for the previous error to be gone.

- **A dynamic dependency resolved by name is unproven until its identity is
  checked.** Where a test loads a pinned native library, the verification step
  reports the loaded file's size or hash, not merely that the run passed.
  Windows' search order makes silent substitution the default failure mode,
  where POSIX tends to fail loudly.
- **When a defect is found on one platform, check the other for the same class
  before closing it.** Both Linux fixes lived inside `if(NOT WIN32)`, so the
  Windows path was never examined until it was run.
- **Scope the doubt honestly when this happens.** Earlier Windows numbers in
  that campaign were all measured on the same machine, where the copy never
  existed, so they are recorded as unconfirmed rather than quietly kept.

## 2026-09-22: a probe that will be committed must be handed over while it exists

Evidence: Soul's fifth Idunn pass settled `resolve()`'s fsck on a real
smart-HTTPS rig and Self ruled the rig should be committed, naming Soul's
files. By the time Hands looked, none survived — no session, no Yggdrasil work
directory, no scratch trace. Hands rebuilt the rig from the map's prose, which
worked **only because the map described it in detail**.

Probes are throwaway by doctrine and that stays true. But the moment Self
rules that a probe becomes a committed test, it stops being scratch:

- **Self records the rig's mechanism in the map in enough detail to rebuild
  it**, not merely that it passed. That description is what saved this one.
- **Better, rule on committing it while the Soul pass is still live**, and
  have Soul hand the files over in its report rather than leaving a path.

## 2026-09-22: Soul was wrong about a redundancy, and a Hands hand-trace caught it

Evidence: Soul's S5-8 reported four containment checks where one sufficed,
each surviving deletion **alone**, and Self ruled three of them deleted. Hands
deleted two, hand-traced the third, and found that with all three gone a
symlink whose entire target is `".."` at the root resolves to the parent of
the root and returns `Ok` — a containment escape — because no later `Normal`
step runs to trip the surviving arm's own check. Hands kept the check, pinned
it with a new test, and recorded the deviation in code.

- **"Each survives deletion alone" does not mean "any two survive together."**
  A redundancy finding must be probed at the combination Self intends to
  delete, not one member at a time. Soul's method was sound and its conclusion
  did not follow from it.
- **A Hands brief must invite this.** The rule that a deletion judged unsafe
  is reported with evidence rather than quietly kept is what produced the
  catch; it stays in the template, and it applies to deletions Self ordered.
