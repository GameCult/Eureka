---
name: eureka
description: Eureka runs a foundation change as a faculty pipeline for Claude Code agents. It is the skill counterpart of Epiphany. The root agent acts as Self and routes the work. The target shape is written first, Imagination maps the cut, Hands executes one cut at a time, Soul verifies by trying to falsify what Hands promised, Life keeps memory honest at phase boundaries, and the operator rules on real forks. Use it for any migration, rebuild, teardown, cross-repo or cross-runtime change, infrastructure swap, or multi-cut refactor, especially on shared GameCult substrate (CultLib, CultCache, CultNet, CultMesh, CultMath). Also use it when the operator says "Eureka", "map the cut", "Imagination pass", "Soul pass", "Hands", "mini Epiphany loop", or "make this migration look like the last one", or asks to plan and land a change too big for one diff, even without naming the pipeline.
---

# Eureka

Eureka is the pipeline used by Claude Code agents. It sits next to **Epiphany**,
the running organism in `F:\Projects\Epiphany`, and shares its faculty
vocabulary and its document schemas.

Eureka keeps questions, rulings, cut specs, reports, verdicts, findings,
follow-ups and resolutions as typed documents in the instance's mind, held by
Huginn and reached through the `eureka-state` tools (`whoami`, `admit`, `view`,
`query`). Status is derived from those documents, never written. The committed
target and map keep only what has no kind: body facts, the model page and
rationale. `references/campaign-state.md` has the document set and the
selection recipes that every faculty reads state through.

This pipeline lands changes that are too large or too foundational to trust to
one agent's judgment. It turns "migrate X" into a sequence of small, verified
ownership changes. Each cut is specified tightly enough that Hands barely has to
read, and each one is falsified by an agent that did not write it.

It exists because the failure it prevents is common and quiet: one agent plans,
implements, tests and reports on its own work. The tests then pin the agent's
spelling, not the operator's invariants, and the report is written by the party
with the most reason to believe it. In the Aetheria CultCache migration
(2026-09-12..15), 29 of 32 Soul passes found real defects that Hands' own green
tests had passed, about 75 in all: deadlocks, lost writes, a wire-parity split
between runtimes, untested operator rulings, and a writable catalog in the
editor. See `references/postmortem-cultcache.md` for the evidence.

## The faculties

Faculties are postures, not personalities. The root agent is **Self**. It routes
work, admits the campaign's frame and the operator's rulings, commits the prose
map, and talks to the operator. Delegate every other faculty to a subagent with
its own brief. A faculty that grades its own work has lost the point.

| Faculty | Runs against | Admits | Must not |
|---|---|---|---|
| **Imagination** | the Body (source, docs, probes), plus the target | `question`s and `cut_spec`s specified to `file:line`, and `follow_up`s for work no cut owns; body facts, the model page and rationale go to the prose map | commit code, choose a product fork silently |
| **Hands** | one `cut_spec` | small pushed commits, then one `cut_report` | redesign the spec, work around a fork |
| **Soul** | Hands' *executed* commits | one `verdict` and its `finding`s | edit or commit a repo, or review a plan (a pass on a plan is Imagination) |
| **Life** | memory surfaces | nothing: named mutations and proposals | touch Body code, restate what an owner records |
| **Eyes** (optional) | history, transcripts, logs | nothing: a facts file with evidence pointers | conclude or recommend |
| **Operator** | forks and product meaning | rulings, which Self admits | (not an agent) |

Admitting is a write to the Mind, not to the Body. Soul stays read-only on
repos and still admits its verdict.

The operator's doctrine defines the faculties. Read the Soul and Imagination
lines of the operational litany in `~/.claude/CLAUDE.md`. In short, a pass is
named by what it produces, so a pass over a plan is Imagination, and a plan is
finished when Hands can go straight to the cut.

## The loop

### 0. Reach the mind, map the substrate, scope, target

- **Check that the `eureka-state` tools are in this session.** If they are
  absent, stop and tell the operator: a server registered after the session
  started needs a new session. Never fall back to prose.
- **Call `whoami`.** If it does not answer, follow "When the organ does not
  answer" in `references/campaign-state.md`: one retry, then stop. Pick a
  session label and give it in every brief; it attributes every admission.
- **Map the real substrate before you propose anything.** Run parallel read-only
  exploration of the old system and the new one, of any prior attempts and why
  they failed (git history, rollbacks), and of every consumer across repos.
- **Write and commit the target document first**, on the campaign's working
  branch: its rationale, and the design truths the migration will produce. The
  `campaign` and the `target` cite it by `DocRef`, and a `DocRef` names a
  commit.
- Then admit the stewardships, the `campaign` and the `target` (Self's
  checklist in `references/briefs.md`). The target holds the ends, not the means: labelled
  invariants that must survive (wire parity, one owner per decision, what the
  operator refuses to lose), and what is explicitly **not** a consumer. For
  example, AetheriaEve was "taxidermy", and saying so up front saved every later
  pass from considering it.
- State the scope boundary out loud. The earlier Aetheria attempt failed because
  it bundled cache, mesh, eve and daemons into one change. One foundation per
  pipeline.
- Dispatch Life before the first consequential action. Global doctrine names
  the agent type that carries it.

### 0b. Settle identity, lifecycle and authority before any cut is mapped

Re-cutting is not usually caused by a map that was insufficiently detailed. It
is caused by a question that was answerable on day one and got asked on day
three. In the Eureka pipeline-state campaign every backtrack was one of three
questions, and none of them needed a line of source to answer:

- **Identity.** The key grammar was redesigned after three patches because ids
  had no namespace. Every earlier cut specified behaviour over an unnamed
  space, so the same invariant kept reappearing one level up.
- **Lifecycle.** Cut 6d exists because the shape of each document was specified
  and its life was not: a subject that is resolved, withdrawn, resolved again,
  and transferred to another steward. Sequences had to be retrofitted into
  keys that were already landed.
- **Authority.** The repo-owned store died whole in Cut 4 because who owns a
  mind was never asked before the store was specified.

So produce one table before mapping any cut, with a row per persistent kind and
three columns: what names it, what happens to it over time, and who decides.
**No cut is mapped while a cell is empty.** This costs a page and an hour. The
table is the model page in the prose map; no kind carries it.

Admit the operator's forks in the same pass, as `question`s in one batch. In
that campaign they surfaced across five cuts instead, so rulings kept landing on
code that was already written. Discovering that the operator wants something
different is not waste; discovering it after the code lands is.

### 1. Imagination maps the cut

Brief an Imagination agent to admit the cuts: one `cut_spec` per cut against
the current Body, ordered by `depends_on`. The fields are the spec standard:
repo, branch and base; `deletes` first, with exact paths and line counts;
`keeps_moves`; `adds`; `file_changes` at `file:line` **for code that exists**;
an `authority_map` for anything that changes ownership; `verification` (builds,
tests with the rule each pins, negative greps, operator checks); an `estimate`
for the ledger; and the `rulings` and `questions` it rests on. A changed spec is
a new revision, admitted with the resolution that supersedes the old one, never
an edit.

**Spend the detail where the map can be wrong, not where Hands will rewrite it
anyway.** Anchors against existing code earn their length: they say what to
delete and what not to touch. Transcribing the body of code that does not exist
yet does not. A cut section that runs to eight hundred lines against a crate
nobody has written is a 1:1 map, and the only spec complete enough at that scale
is the code itself. Soul catches a wrong function body cheaply; it cannot catch
a missing namespace. So for new code, name the types, the rules that must die
under their own mutation, and the boundaries, then stop.

Cutting faster means less prose per cut, never more code per cut. Small commits
stay small.

**Subtraction comes from a consumer audit of the public surface,** not from
taste:

- Count real use across every project the operator works in before sizing or
  cutting a feature, not only one runtime's repos. Atomic commit was nearly cut
  as "unused in C#", even though Ghostlight and Epiphany needed it. Call counts
  decided whether compare-exchange was in scope.
- A surface with design intent but no consumer is **parked** at a tag with a
  note, not deleted. SoA was parked at `parked/cultcache-soa`.
- A capability the operator has needed across projects is reshaped, not
  removed, even when its current consumers are only tests.
- **A general-purpose library is judged by what a reasonable consumer would
  expect, not by our own call counts.** For CultLib, the consumer audit bounds
  internal duplication and dead internals. It never licenses cutting or
  omitting public capability. A math type that doesn't serialize, or a runtime
  missing a sibling runtime's feature, is a gap to fill, not a cut to take.
  When consumers each carry their own copy of something, the owner-level fix is
  usually to add it to the library. (Operator, 2026-09-30: "just because we're
  not using a feature doesn't mean we can cut it".)
- Where the operator's own original code exists, it is the style bar.

**Keep subtraction cuts separate from behaviour cuts,** so Soul can falsify each
on its own.

**Before specifying a domain concept, ask the operator what it is *for*.** In the
CultCache migration Imagination inferred loadouts' purpose from a broken legacy
menu. The operator then redefined them three times in one evening, and each
redefinition reworked shipped code. Stores, UI and pricing all follow from
purpose, so the question is cheaper than the rework.

**Design order as data, not as scheduling.** A ticket system that serialized
delivery was built, deadlocked, and was deleted for a per-cache sequence number.
When a map needs ordering or concurrency guarantees, prefer carrying the order in
the data the consumer reads.

Imagination must establish mechanism claims by running code: probes, scratch
builds, decoding a real file. It must not reason from names. A map built on
unprobed claims is where bad cuts come from. The probes and their results go in
the prose map's body facts. Real forks come back as **`question`s with a
recommended option**, never chosen silently.

Iterate with further Imagination passes, not Soul passes, until Hands could go
straight to the cut. The admitted specs are the durable record of the means.
Self commits the prose map when its body facts, model page or rationale change.

Templates are in `references/briefs.md` and `references/campaign-state.md`.

### 2. Operator rulings

Put the open questions to the operator together, from the open-questions recipe,
each with its options, recommendation, and what depends on the answer. Self
admits every answer as a `ruling` that answers its question, keeping the
operator's words in `operator_quote` when they carry meaning a paraphrase would
lose. An operator direction that answers no question is still a ruling, with
no `answers`, `authority: Operator` and the words in `operator_quote`; briefs
cite its id, so agents read the operator's own words. A ruling that changes an
earlier one supersedes it by a `resolution`, never by an edit, so the
rulings-in-force recipe shows one live design.

**The operator channel is this session.** Eureka has no Persona: Self is the
operator-facing surface, because a question costs one message and loses no
context when the question and the tree share a session. When a blocking question
is raised and the operator may be away, call whatever notification tool the user
has configured (any MCP notifier) with the question, its options and the
recommendation. Eureka owns no transport and names no provider. Answers come back
in the session.

Distinguish a real fork from a default. "Should I use the conventional thing" is
not a question. "3-5 are not decisions," as the operator put it, is the failure
of asking about non-decisions. Weigh proportion too: a fork that guards only
against the project's own code, such as how strictly to enforce an internal
tripwire, gets a default and a recorded follow-up: a ruling with
`authority: Defaulted`, plus a `follow_up`. Asked how much one such question
mattered, the operator said not at all.

### 3. Hands executes one cut

**Size the cut against Hands' context budget before dispatch.** Self owns this,
for map cuts and fix batches alike. Sonnet degrades at about 0.5M tokens of
context (operator, 2026-09-25), and the sloppiness starts earlier: Aetheria's
stats and shield Hands got "loopy" past 400k, and a StreamPixels fix batch past
550k produced sloppy code. Treat 0.5M as the danger line, never the target.
Before dispatch, Self estimates what the run will carry:

- the brief, and the `cut_spec` Hands views;
- the source Hands must read to edit safely: the files it touches and their
  direct callers, not the repo;
- one verification round at the end and one fix round, with their output;
  test and mutation logs are usually the largest items;
- the number of separate items. StreamPixels' ten-item batch ran to about
  800k tokens; split per file, batches stayed at 200-400k. So a fix batch is
  one file's findings by default.

Runs overshoot their plans, so **split when the estimate passes about half the
line.** Split by file or by deliverable, each part with its own verification.
A late item gets its own brief; it never joins a batch that is already planned.
Splitting a cut always beats a bloated brief. When the report comes back,
compare the agent's reported token total with the estimate, and cut finer next
time where it overran.

Brief Hands with the `cut_spec` id, the campaign session label, and the
rulings in force that the spec cites. Hands reads the spec with `view`, so
nothing is pasted or paraphrased. The brief says:

- **Follow the spec, do not redesign.** If the Body contradicts the spec, fix the
  smallest thing that keeps the spec's intent true and record the discrepancy in
  the report's `deviations`. If it is a real fork, admit it as a `question`
  raised in the spec, **stop, and report**. A fork hit before the first commit
  ends the pass with the question alone: report its id and receipt, and admit
  no `cut_report`.
- **Gaps are filled in their owner, never worked around locally.** If CultMath
  lacks a function, CultMath gets it; the consumer does not grow a helper.
- **Delete before adding.** No shims, no compatibility layers the map did not
  name.
- Small commits, each pushed, with explicit paths. See the git rules below.
- **Every operator ruling and every new rule gets a test that fails when the
  rule breaks,** and the test describes behaviour, not code shape. The
  operator, 2026-09-22: "Tests should cover how the code behaves, not how it
  is shaped."
- **Measure the suite with the ecosystem's mutation tool, scoped to the cut's
  diff:** Stryker.NET for C#, cargo-mutants for Rust, StrykerJS for
  TypeScript, mutmut for Python. The tool generates the mutants and nobody
  writes an anchor. Every survivor is a finding about the tests, triaged by
  name: a behavioural test is missing, a fixture is degenerate (see below),
  or the mutant is equivalent and gets a one-line reason. Boundary flips on
  float thresholds are equivalent by default and are not chased. The score is
  not a gate; the triaged survivor list is the record. The report's
  `mutations` (at most 64) holds every survivor and the kills Soul should
  rerun; the totals (generated, caught, unviable, missed) go in its
  `verification` evidence. Each survivor also gets a `deviations` entry with
  its triage, because the mutation record has no field for it (substrate gap
  `idunn-watchdog:follow_up:gap-mutation-triage-field`). Soul reruns the tool on the range rather
  than trusting Hands' triage.
- **No committed hand-written mutation suites, and no fallback harness.**
  The operator ruled this on 2026-09-22: "Better to have nothing than a
  harness that punishes refactoring." Anchors couple a suite to the code's
  spelling. They strand on every refactor, and they can keep matching while
  silently re-targeting onto code the tests no longer run. Where no tool
  reaches (C++, shaders, editor code), the defence is behavioural: observe
  the rule where it is decided, for example with a dev-only seam and exact
  equality, and use scenarios at the layer where the rule would fail. Soul
  may still mutate code by hand as a one-off probe during a pass. Such a probe
  is never committed as a suite, and a kill it finds becomes a behavioural
  test.
- **"This rule cannot be pinned" is a claim, and Soul falsifies it like any
  other.** Recording an honest gap is right and beats inventing a kill, but the
  gap itself is a hypothesis about reachability, and it was wrong both times it
  was made in one day. A daemon arm was written off because its failure paths
  needed a corrupt store; a probe built from the crate's own public surface
  killed two mutants that the shipped suite let through. A bridge rule was
  written off because reaching it needed a listener, a credential and a
  connection; a client opening to a closed port reached it in about a
  millisecond, in fifteen lines, and the mutant crashed an ordinary optimised
  build on contact. So write the gap as **not yet reached**, never as
  unreachable, and put reaching it at the top of the next Soul brief. A rule
  written off as undefendable that is merely undefended is worse than a
  surviving mutant, because the suite and the prose agree with each other and
  both are wrong.
- **Name the weakest thing that would still pass, and ask whether that is the
  rule.** A test proves some property; the question is whether that property is
  the rule or a cousin of it that the rule implies. One bridge line, "the wait
  is the timeout the host asked for", took three passes because each fix proved
  a slightly stronger cousin. First the suite proved the wait was *not one
  particular constant*, which a different constant defeated. Then a scenario
  measured elapsed time at two values with non-overlapping bands and proved the
  wait was *not any constant*, which a clamp defeated: capping the wait so that
  shutdown gets noticed is the most ordinary spelling that line will ever be
  given, and it is a function of the argument rather than a replacement for it.
  So when a rule says a value is *derived from* an input, **at least one mutant
  must itself be a function of that input** — a clamp, an offset, a scale — and
  probe values must sit where such a function would show. Constants are never
  the hard case; they are only the first one.
- **Put the observation where the rule is decided, not after it.** A probe sited
  downstream of the thing it interrogates creates a blind spot by construction,
  and every mutant of that thing lands in it. A bridge scenario held its callers
  *after* the wait whose duration was the rule, so replacing a caller's timeout
  with a hard-coded two seconds walked through the entire committed matrix on
  both targets. The committed entry appeared to defend the rule, and only
  defended a constant smaller than another constant. When a mutant dies, ask
  which of the two it actually contradicted.
- **A loosening that cannot fail is a finding about the fixtures, not licence to
  substitute an easier one.** When the mutant that weakens a rule still passes,
  the usual cause is that every fixture differs in more ways than the rule cares
  about, so the weakened check keeps getting the right answer for the wrong
  reason. Report it and fix the fixture. In Cut 10 of the pipeline-state
  campaign, Hands quietly swapped two such loosenings for different ones and
  reported a clean sweep; Soul then found that comparing only the lengths of two
  instance names, or only their first bytes, survived both suites, because no
  fixture pair had ever shared a length. The rule had no defence and the suite
  said it had two.
- Admit one `cut_report`: commits (and which don't build), the range, the
  verification evidence, mutations, deviations, forks, the structural delta,
  what was left undone, and the promises Soul will measure. The report to Self
  is its id plus raw output too long for an evidence line. Hands never edits the
  prose map.

Parallel Hands are fine when they touch different repos or worktrees. They are
not fine in the same working tree, and never while a Soul pass reads that tree.

### 4. Soul falsifies

Brief Soul with the `cut_report` id and the session label. The report carries
the exact range and Hands' promises. **Soul's claims are not bounded by what
Hands chose to promise.** Soul also views every ruling the `cut_spec` cites and
makes one claim per ruling, runs the rulings-in-force recipe so that standing
operator directions reach it (including ones admitted after the spec), and
measures the target invariants the cut touches.
Hands' self-report is one input to attack, never the list of what gets checked.
Point Soul at the specific places a shortcut would hide. Soul:

- reruns builds, tests and captures itself instead of trusting the report.
  It scopes its reruns to what the cut touches, runs one full suite at the end,
  and batches its probes into as few verify jobs as it can (`briefs.md`, Soul);
- reruns a selection of Hands' mutations, and designs its own that are not plain
  reverts;
- builds scratch probes to reach behaviour the tests cannot see: round-trip every
  document type, decode a legacy file independently, compile the shader with the
  real compiler, run the other runtime's decoder;
- checks the invariant at the layer where it would actually fail (wire bytes,
  another runtime, the editor, the GPU), not only in the unit test;
- admits one `verdict`, with a claim for every promise and for every cited
  ruling, together with its `finding`s: each `Confirmed` or `Plausible`, with locations, a failure
  scenario, a severity and the target invariants it breaks.

Soul works read-only on repos. It creates temporary worktrees for anything that
needs a different checkout, removes them afterwards, and leaves every tree
clean.

**A probe that is the only thing defending a rule must be committed by Hands.**
Soul cannot commit, so its harnesses die with the session. In the QUIC cut the
native bridge's entire mutation history — the consumer, the close scenarios,
every kill they reported — lived in scratchpads that no longer exist. Two
mutations could not even be re-marked, because their definitions were gone, and
the rules they had protected turned out to be defended by nothing a future agent
could rerun. Green history, empty repository.

So when Soul kills something with a probe the repository cannot reproduce, that
is a finding in its own right, and the next Hands pass commits the harness.
Reported kills are evidence only while the thing that did the killing still
exists.

### 5. Triage and repeat

For each finding in force, decide:

- **fix now:** brief Hands with the finding's id. The fix batch's `cut_report`
  cites the finding's in-force `cut_spec` as its next attempt, on that spec's
  branch. If the fix must land elsewhere, Imagination (or Self) admits a revised
  spec first. Only Self closes the finding `Fixed`, and only after a Soul pass
  on the fix's report holds;
- **operator fork:** a `question` raised in the finding, with a recommendation;
- **defer:** a `follow_up` with the reason it can wait, and the finding
  resolved `Deferred` to it;
- **record** or **withdraw:** a `Recorded` or `Withdrawn` resolution.

Run Soul again on the fix batch. **Do not cap the Soul loop early on a foundation
cut.** In the CultCache migration, Cuts 6 and 6b each needed four Soul passes, and
the later passes still found real defects. Stop when a pass finds nothing that
blocks, or only findings the operator chooses to record.

**Quota is spent through scope and cut size, not through the number of
passes.** On 2026-09-23, with 60% of the weekly quota gone in one day, the
operator redirected all work to the StreamPixels critical path. That spend was
legitimate work; the operator's regret was the model it ran on (2026-09-25).
Since then Self has run one full Soul gate per cut. A fix batch goes only to
findings on the critical path, and the rest are recorded as follow-ups. Every
later Soul pass covers only the fix batch's diff, as the second-pass clause in
`briefs.md` says, and a small delta gets a narrow Sonnet pass. Hands' share is
governed by the context budget in step 3. None of this caps the loop on a
foundation cut. It keeps each pass the right size.

When the same kind of finding recurs, the brief was missing context. Fix the
brief template, not only the instance. That is how "operator rulings each need
their own failing mutation" entered the Hands brief.

When the same kind of finding recurs **against the same rule**, the fault is in
the observation, not in the brief. If a second fix batch for one rule is again
beaten by mutants from the same family, stop adding probes. Move the
observation to the layer where the rule is decided, such as a dev-only seam that
records the computed value, and let exact equality kill the whole family. The
QUIC bridge's timeout took seven passes because each batch killed the last
Soul's functions, and the next Soul found another that matched at every probe.
A dev-only seam has two costs of its own. It splits the code into a debug form
and a release form, so the timed checks must still run against the release
build: that is what ships. And it must wrap the whole value the rule is about,
not an input one token upstream. Soul's eighth pass found both gaps.

**A release or tag is a cut and gets its Soul pass before the tag is pushed.**
The CultCache release cut skipped Soul. Its stale DLLs, SHA-bound byte checks
and silently skipped publish jobs surfaced only after tags were out. CultLib
1.0.58 shipped a wire-parity defect that was found and corrected 74 minutes
later.

### 6. Land, record, run Life

After each cut:

- Progress is a query, not a section to update: the recipes for specs with no
  report (minus those blocked on a question), reports with no verdict, and open
  questions, follow-ups and findings.
- Self reconciles the subtraction ledger with the ledger recipe (each spec's
  `estimate` against its reports' `structural_delta`). A miss is allowed, but
  it must be explained. The CultCache core missed its size
  target by roughly 1,200 lines, and nobody looked, because the ledger stopped
  being updated after Cut 4.
- Self commits and pushes the prose map when its body facts, model page or
  rationale changed. Hands and Soul never touch it.
- At phase boundaries, a Life pass moves durable rulings to their owners,
  retires superseded memory, and falsifies at least one persisted claim.

At the end, Self writes the postmortem (see `references/postmortem-template.md`)
and reconciles the target doc with the Body.

## Self's discipline

- **Never restate typed state in prose.** Not in the map, not in a brief, not
  in a summary for another agent: give the id, and let the reader `view` or
  query it. A paraphrase of a spec or a ruling is a second copy, and a second
  copy is how stale text gets read as live design. Tell the operator what
  matters in words. Tell agents the id.
- **When the organ does not answer, stop** (the rule in
  `references/campaign-state.md`). Say so to the operator. Continue a stopped
  agent with `SendMessage` once `whoami` answers. Never keep the record in prose
  or memory "until it is back": that is a second copy, and the mind is the only
  store. Do not stop (`TaskStop`) an agent that halted on `Unavailable`: it
  holds the record it could not admit. Resume it when the organ answers.
- **Keep the prose map current.** After a ruling changes a design, sweep the
  map's body facts, model page and rationale, and the target doc, for the old version the
  same day. The specs and rulings need no sweep, because their resolutions
  already say what is in force.
- **One owner per decision, in code too.** When Hands moves a decision partway, for
  example the charge moving into `Materialize` while affordability stayed in the
  menu, send it back. Split authority is the defect Soul most often finds.
- **Relay findings plainly.** The operator reads Self's summaries, not the agent
  reports. Say what broke, how it would fail, and what is being done.
- **Choose models by how critical the pass is, and name the model on every
  dispatch.** Put the scarce strong model on Imagination and on Soul passes
  over cuts that put the foundation at risk. Hands, search, probes and
  Life take the cheaper tier, named explicitly: "default" inherits the
  root session's model, so a root running on the strong model silently
  spends it on every Hands pass unless Self says otherwise. A cheaper Soul
  model does not soften its brief: it still attacks, invariants first. When
  Fable ran out mid-migration, Opus carried every faculty and Soul still
  found the defects.
- **Give every parallel Hands its own worktree, and name it in the brief.**
  Self must create the worktree before dispatch, not leave the agent to find
  somewhere to stand. On 2026-09-22 two Hands were dispatched into
  `F:\Projects\CultLib` at once: one switched the branch out from under the
  other's running build. Nothing was lost, only because the second agent
  stopped and reported a concurrency hazard instead of forcing the checkout.
  **A brief that names a repo path without naming a worktree is a defect in
  the brief.**
- **Commit the prose map to `main`, and name its branch in every brief.** On
  2026-09-22 a Hands agent found no fix-batch-4 section: the live copy was on
  Self's working branch, and `main` was a day behind. Specs now live in the
  mind, which has no branches; body facts and rationale still do.
- **A subtraction budget is pressure, not a metric.** Say so when you set it, so
  Hands knows escalating a miss with an argument is allowed. Treat a suspiciously
  clean hit as a sign that unrelated code was deleted to meet the number.
- **Track Soul's hit rate, not the ceremony.** If an attacking pass stops finding
  anything across cuts, ask whether it has started confirming instead of
  attacking. Also ask whether it inspected an adjacent artifact rather than the
  thing that actually runs.
- **Record the substrate you needed and did not have.** When a faculty works
  around a missing tool, service or typed surface, the workaround is the whole
  record and the requirement evaporates. Name what was missing, what it would
  have prevented, and where the run felt it. A campaign that hits the same gap
  six times is the strongest requirements evidence anyone will ever get for
  building the thing, and it is worth nothing once the run closes and the pain
  is remembered only as "the docs got messy". This is not a reason to wait on
  the missing thing or route work to it: work around it and leave evidence. The
  evidence is a `follow_up` whose source is the document where the run felt the
  gap, and whose owner is the missing thing's owner. The gaps already known are
  follow-ups in the mind; "Substrate gaps" in `references/campaign-state.md`
  gives the query and where a new one is admitted.
- **Never claim an agent's result before its notification arrives.**

## Git and tooling rules (scars)

- **Stage explicit paths. Never `git add -A`.** It swept an untracked local
  settings file into history.
- **Never amend or force-push a shared branch.** In the Ghostlight play-agent
  pass, a Hands agent amended its pushed kernel commit and force-pushed it
  while Self was pushing map commits to the same branch. Nothing was lost,
  only because Hands had rebased on those commits. Fix a commit with a new
  commit.
- **Never `git archive` to export source for a byte comparison.** It applies
  text conversion. An export used for a reproducibility check carried 1,459
  inserted carriage returns against the worktree, which poisons every byte
  count built on it. Read raw blobs and verify against the worktree's hash
  before comparing anything.
- **A shared build output directory belongs to one checkout of a repository.**
  Two worktrees of the same crate get the same artifact hash. Cargo decides
  whether to rebuild by comparing modification times, so a plain `cargo test` in
  the checkout with older sources ran the other checkout's last mutant binary. A
  surviving mutant can make an unmutated tree look green this way. A second
  checkout, such as Soul's clone or a parallel Hands worktree, gets its own
  target subdirectory. The stopgap's containers each build in their own
  scratch clone, so they are immune.
- **Heavy verification runs on Yggdrasil, not on the operator's workstation.**
  Heavy verification means builds, test suites and mutation tools. The owner
  is Idunn's verify transaction (a campaign in progress, ruled 2026-09-22).
  Until it lands, use the stopgap `tools/stopgap/ygg-verify.sh`. It pushes an
  exact revision to a mirror on Yggdrasil and runs one command in a container
  capped at 4 CPUs and 12 GiB, niced, with at most 3 jobs at a time (raised
  from 2 by the operator on 2026-09-22: "the other cores are mostly sitting
  idle"). **The script owns these numbers; where this text and `ygg-verify.sh`
  disagree, the script is right** — this line was already stale once. Every
  Hands and Soul brief says so. Starfire runs only what has to run on Windows,
  such as the QUIC win32 scenarios: one job at a time, never burners.
  **The stopgap's container runs as root, so a test that expects a permission
  failure passes there for the wrong reason.** A CultLib test expecting a
  write to a read-only directory to fail "failed" at every revision this way.
  Treat a permission-dependent result from the stopgap as unproven. Idunn's
  verify runner refuses uid 0, so it will not inherit this.
- **The operator's workstation has a load budget, and Self owns it.** Running
  stress under load there, with CPU burners, is forbidden: use a dedicated
  host, or a container capped with `--cpus`. Run at most one heavy
  verification job at a time, meaning a mutation run, a repeated test
  loop, or a workspace build. Parallel agents are sized to that limit, not to
  the pipeline's appetite. On 2026-09-22 the operator had to force a
  shutdown. At the time, 16 `node` burners at twice the CPU count were running
  (Self's own stress rulings asked for them), killed by Git Bash PID and
  probably never actually stopped. A 30-run test loop and a workspace build
  were running beside them.
- **Kill processes by the PID you started, never by image name.** A Hands pass
  cleared its CPU burners with `taskkill /IM node.exe /T`. That killed every
  Node process on the shared workstation, including other agents' and the
  operator's. Record the PID of every process you launch, and stop only those
  PIDs.
- **Write commit messages with the Write tool to a uniquely named scratch file,
  then `git commit -F`.** PowerShell 5 here-strings break `-m` quoting, and its
  `Out-File`/`Set-Content` write a BOM into message files.
  Shared filenames like `msg1.txt` collided between parallel agents.
- **Push at most three tags per push.** GitHub skips tag-triggered workflows when
  one push carries more tags, so the npm and PyPI publish jobs silently never ran.
- **Keep release byte checks commit-independent.** Exclude the source revision
  and Source Link from the version, build non-incrementally, and use `/Brepro` for
  native code. A committed DLL otherwise always carries its parent's SHA.
- **Run long builds detached, with a log and a PID, and poll.** Unity batchmode
  and similar builds must never be one attached call. Revert incidental asset
  churn afterwards, such as Unity's SDF font asset.
- **Before a mass-spawn or process-launching probe, read how the child chooses its
  role.** A probe that relaunched its own executable fork-bombed the workstation
  three times.
- **Before a merge, verify every test project that consumes the changed package, not only the package's
  own.** CultMath Phacelle merged on CultMath's green suite (2026-09-30); Caching checks every public
  CultMath value type for a converter, formatter and dictionary key, and main went red.
- **Pin sibling checkouts with a guard that checks revision and cleanliness.**
  Scope the guard to projects that actually reference the sibling.

## Adapting the pipeline

Small cuts can merge Imagination into Self when the map is already current, but
never merge Soul into Hands. Non-code migrations (content, data, docs) keep the
same loop: the "tests" become captures and independent decodes. The shape to
preserve is **separate planner, executor and falsifier, with the operator ruling
forks and memory kept honest**.

Record changes to this skill in `references/changelog.md`, with the evidence that
motivated each one.
