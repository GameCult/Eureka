---
name: eureka
description: Eureka runs a foundation change as a faculty pipeline for Claude Code agents. It is the skill counterpart of Epiphany. The root agent acts as Self and routes the work. The target shape is written first, Imagination maps the cut, Hands executes one cut at a time, Soul verifies by trying to falsify what Hands promised, a Mind Steward keeps memory honest at phase boundaries, and the operator rules on real forks. Use it for any migration, rebuild, teardown, cross-repo or cross-runtime change, infrastructure swap, or multi-cut refactor, especially on shared GameCult substrate (CultLib, CultCache, CultNet, CultMesh, CultMath). Also use it when the operator says "Eureka", "map the cut", "Imagination pass", "Soul pass", "Hands", "mini Epiphany loop", or "make this migration look like the last one", or asks to plan and land a change too big for one diff, even without naming the pipeline.
---

# Eureka

Eureka is the pipeline used by Claude Code agents. It sits next to **Epiphany**,
the running organism in `F:\Projects\Epiphany`, and shares its faculty
vocabulary. The difference is substrate:
- **Epiphany** keeps its findings in typed, admitted state that can be queried
  by exact filter. Epiphany removed her own vector stack in `856648de`;
  semantic search is planned through the Huginn memory organ, which depends on
  Qdrant directly.
- **Eureka** currently keeps them in committed docs (the target and the cut
  map), subagent reports and memory files.

Giving Eureka agents typed state tools is the intended next step; see
`references/changelog.md`.

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
work, keeps the maps, commits the maps, and talks to the operator. Delegate every
other faculty to a subagent with its own brief. A faculty that grades its own
work has lost the point.

| Faculty | Runs against | Produces | Must not |
|---|---|---|---|
| **Imagination** | the Body (source, docs, probes), plus the target | the cut map: the target shape specified to `file:line` | commit code, choose a product fork silently |
| **Hands** | one cut of the map | small pushed commits, a report with evidence | redesign the spec, work around a fork, update the map |
| **Soul** | Hands' *executed* commits | findings, CONFIRMED or PLAUSIBLE, each with `file:line` and a failure scenario | edit, commit, or review a plan (a pass on a plan is Imagination) |
| **Mind Steward** | memory surfaces | named mutations and proposals | touch Body code, restate what an owner doc already records |
| **Eyes** (optional) | history, transcripts, logs | a facts file with evidence pointers | conclude or recommend |
| **Operator** | forks and product meaning | rulings | (not an agent) |

The operator's doctrine defines the faculties. Read the Soul and Imagination
lines of the operational litany in `~/.claude/CLAUDE.md`. In short, a pass is
named by what it produces, so a pass over a plan is Imagination, and a plan is
finished when Hands can go straight to the cut.

## The loop

### 0. Map the substrate, scope, target

- **Map the real substrate before you propose anything.** Run parallel read-only
  exploration of the old system and the new one, of any prior attempts and why
  they failed (git history, rollbacks), and of every consumer across repos.
- Write the **target document**: the ends, not the means. Name the invariants
  that must survive (wire parity, one owner per decision, what the operator
  refuses to lose), the canonical implementations, and what is explicitly **not**
  a consumer. For example, AetheriaEve was "taxidermy", and saying so up front
  saved every later pass from considering it.
- State the scope boundary out loud. The earlier Aetheria attempt failed because
  it bundled cache, mesh, eve and daemons into one change. One foundation per
  pipeline.
- Dispatch the Mind Steward before the first consequential action.

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
**No cut is mapped while a cell is empty.** This costs a page and an hour.

Assemble the operator's forks in the same pass, as one batch. In that campaign
they surfaced across five cuts instead, so rulings kept landing on code that was
already written. Discovering that the operator wants something different is not
waste; discovering it after the code lands is.

### 1. Imagination maps the cut

Brief an Imagination agent to produce the **cut map**: an ordered list of cuts
against the current Body. Each cut carries:

- repo and branch;
- **deletes first**, with exact paths and line counts;
- keeps and moves;
- adds;
- per-file changes with `file:line` against a named HEAD, **for code that
  exists**;
- an **authority map** for anything that changes ownership: owner, inputs,
  outputs, derived state, forbidden writers, shared paths, deletion line;
- **verification**: exact builds, tests with the rule each one pins, negative
  greps, and what only the operator can check;
- a subtraction-ledger estimate.

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
unprobed claims is where bad cuts come from. Real forks come back as **explicit
operator questions with a recommended option**, never chosen silently.

Iterate the map with further Imagination passes, not Soul passes, until Hands
could go straight to the cut. Commit the map; it is the durable record of the
means.

Templates are in `references/briefs.md` and `references/cut-map.md`.

### 2. Operator rulings

Bundle the open questions. Give each one options and a recommendation, and say
what depends on the answer. Record every ruling in the map, dated, with the
operator's words when they carry meaning the paraphrase would lose. When a ruling
supersedes an earlier one, mark the old text as history instead of leaving two
live designs.

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
tripwire, gets a default and a recorded follow-up. Asked how much one such
question mattered, the operator said not at all.

### 3. Hands executes one cut

Brief Hands with the cut's section of the map, the standing rulings restated
briefly, and the verification. The brief says:

- **Follow the spec, do not redesign.** If the Body contradicts the spec, fix the
  smallest thing that keeps the spec's intent true and report the discrepancy. If
  it is a real fork, **stop and report**.
- **Gaps are filled in their owner, never worked around locally.** If CultMath
  lacks a function, CultMath gets it; the consumer does not grow a helper.
- **Delete before adding.** No shims, no compatibility layers the map did not
  name.
- Small commits, each pushed, with explicit paths. See the git rules below.
- **Every operator ruling and every new rule gets a test that fails under its own
  mutation.** Hands runs the mutations against the final spelling of the code and
  restores afterwards.
- **The harness lives here, in `tools/eureka-mutations.ps1`,** not in whichever
  repo happened to need it first. It takes `-Repo`, `-Entries`, `-Target`,
  `-Test` and `-TimeoutSeconds`, so one copy serves every campaign and a fix to
  it fixes all of them; it was moved out of Epiphany once a second repo started
  reaching across for it. A repo whose suites cannot run under PowerShell keeps
  its own runner and owes the same contract by name: a no-op control, byte-exact
  restore verified by hash, a sidecar written before any write, anchors matching
  exactly once, an honest exit status, and the child's output on a red control.
- **Every mutation suite is a committed script with a no-op control.** The
  control rewrites the target through the same I/O path with no change and must
  leave every test green; if it kills anything, the harness is broken and every
  verdict from it is fiction. File I/O is byte-exact (symmetric UTF-8, line
  endings preserved), anchors match exactly once, and restore is a reverse
  write. This applies to Soul's harness as much as Hands': the one that faked a
  kill was Soul's own inline script, and it is not on disk to be checked.
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
- Report: commits (and which don't build), verification output, mutation
  results, spec discrepancies, forks, structural delta. Hands never updates the
  map.

Parallel Hands are fine when they touch different repos or worktrees. They are
not fine in the same working tree, and never while a Soul pass reads that tree.

### 4. Soul falsifies

Brief Soul on the exact commit range, with the operator invariants and Hands'
promises listed as claims to falsify. Point it at the specific places a shortcut
would hide. Soul:

- reruns builds, tests and captures itself instead of trusting the report;
- reruns a selection of Hands' mutations, and designs its own that are not plain
  reverts;
- builds scratch probes to reach behaviour the tests cannot see: round-trip every
  document type, decode a legacy file independently, compile the shader with the
  real compiler, run the other runtime's decoder;
- checks the invariant at the layer where it would actually fail (wire bytes,
  another runtime, the editor, the GPU), not only in the unit test;
- reports each finding as CONFIRMED or PLAUSIBLE, with `file:line`, a failure
  scenario and severity, then lists the promises that held.

Soul works read-only. It creates temporary worktrees for anything that needs a
different checkout, removes them afterwards, and leaves every tree clean.

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

For each Soul finding, decide:

- **fix now:** brief Hands with the finding and the target shape;
- **operator fork:** ask, with a recommendation;
- **record as a follow-up:** the map gets the item, the file and the reason it can
  wait.

Run Soul again on the fix batch. **Do not cap the Soul loop early on a foundation
cut.** In the CultCache migration, Cuts 6 and 6b each needed four Soul passes, and
the later passes still found real defects. Stop when a pass finds nothing that
blocks, or only findings the operator chooses to record.

When the same kind of finding recurs, the brief was missing context. Fix the
brief template, not only the instance. That is how "operator rulings each need
their own failing mutation" entered the Hands brief.

**A release or tag is a cut and gets its Soul pass before the tag is pushed.**
The CultCache release cut skipped Soul. Its stale DLLs, SHA-bound byte checks
and silently skipped publish jobs surfaced only after tags were out. CultLib
1.0.58 shipped a wire-parity defect that was found and corrected 74 minutes
later.

### 6. Land, record, steward

After each cut:

- Self updates the map's status header: what landed at which SHAs, what was
  verified, what Soul found, what was recorded.
- Self reconciles the subtraction ledger against what actually landed. A miss is
  allowed, but it must be explained. The CultCache core missed its size target
  by roughly 1,200 lines, and nobody looked, because the ledger stopped being
  updated after Cut 4.
- Self commits and pushes the map. Hands and Soul never touch it.
- At phase boundaries, a Mind Steward pass moves durable rulings to their owners,
  retires superseded memory, and falsifies at least one persisted claim.

At the end, Self writes the postmortem (see `references/postmortem-template.md`)
and reconciles the target doc with the Body.

## Self's discipline

- **Keep the maps committed and current.** Hands will read stale text as live
  design. After a ruling changes a design, sweep the map and the target doc for the
  old version the same day.
- **One owner per decision, in code too.** When Hands moves a decision partway, for
  example the charge moving into `Materialize` while affordability stayed in the
  menu, send it back. Split authority is the defect Soul most often finds.
- **Relay findings plainly.** The operator reads Self's summaries, not the agent
  reports. Say what broke, how it would fail, and what is being done.
- **Choose models by how critical the pass is, and name the model on every
  dispatch.** Put the scarce strong model on Imagination and on Soul passes
  over cuts that put the foundation at risk. Hands, search, probes and
  stewards take the cheaper tier, named explicitly: "default" inherits the
  root session's model, so a root running on the strong model silently
  spends it on every Hands pass unless Self says otherwise. A cheaper Soul
  model does not soften its brief: it still attacks, invariants first. When
  Fable ran out mid-migration, Opus carried every faculty and Soul still
  found the defects.
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
  the missing thing or route work to it: work around it and leave evidence.
- **Never claim an agent's result before its notification arrives.**

## Git and tooling rules (scars)

- **Stage explicit paths. Never `git add -A`.** It swept an untracked local
  settings file into history.
- **Never `git archive` to export source for a byte comparison.** It applies
  text conversion. An export used for a reproducibility check carried 1,459
  inserted carriage returns against the worktree, which poisons every byte
  count built on it. Read raw blobs and verify against the worktree's hash
  before comparing anything.
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
