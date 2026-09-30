# Brief templates

These are starting points. Fill in every `<>` placeholder. Each brief should let
its agent act without asking what the invariants are. Campaign state is typed:
a brief gives ids and recipe names, and never pastes or paraphrases a spec, a
ruling or a finding. The agent reads those itself. Recipes are in
`campaign-state.md`.

Every brief that reads or admits campaign state carries:
- the campaign slug `<c>`, and the session label `<session>` for its
  admissions;
- the Rehydrate block below, as the agent's first step, with `<recipes>` set to
  the recipes that brief names.

This block is the one definition of rehydration; the other files point here.

## Contents
- Rehydrate (every faculty that touches campaign state)
- Self: open a campaign, rule, triage
- Imagination: settle identity, lifecycle and authority
- Imagination: map or refresh a cut
- Hands: execute a cut
- Soul: falsify executed work
- Life: phase boundary
- Eyes: gather evidence

---

## Rehydrate

```
Campaign state lives in the instance's mind, through the eureka-state tools
(whoami, admit, view, query). Recipes are in references/campaign-state.md.
0. If those tools are not in your tool surface, stop and report that. Never
   work from prose or memory instead.
1. Call whoami. On Unavailable, retry once; if it still does not answer, stop
   and report the error. Self will continue you once the mind answers.
2. Run the campaigns recipe. If there is no campaign, or <c> is not among
   them, stop and report which.
3. Run <recipes>, with root = <c>, and view every id this brief names.
Admit as faculty <Faculty>, agent <your name>, session <session>. A refusal
names the rule that refused: fix the batch and admit again. InvalidInput and
TooLarge are the same: fix the call (or narrow it) and retry. Retrying an admit
is safe (AlreadyAdmitted). Unavailable after one retry, any other isError, or
the mind going away mid-pass: stop where you are and report the step; never
send your record as prose.
```

## Self: open a campaign, rule, triage

Self's own checklist; Self admits as `SelfFaculty`.

```
Open: check the eureka-state tools are present, then whoami (the mind's
instance document, <instance>:instance:self, already exists). Write the target
document and commit it on the working branch. For each repo in scope with no
stewardship in force, admit a stewardship (sequence = latest + 1). Then admit
the campaign (slug, title, every repo a cut may touch, working_branch,
target_doc = a DocRef to that commit) and target revision 1 (labelled
invariants, not in scope, canonical implementations, doc = the same DocRef).
In the first campaign, admit a follow_up for each substrate gap listed in
campaign-state.md.

Rule: for each operator answer, a ruling (answers, choice, authority, and
operator_quote when the words matter). A direction that answers no question is
a ruling with no answers, authority Operator, and the words verbatim in
operator_quote. A changed ruling carries a resolution superseding the old one,
in the same batch.

Triage each open finding: a Hands brief, then a Fixed resolution admitted by
Self only after a Soul pass on the fix's report holds; a question raised in the
finding; a follow_up plus a Deferred resolution; or a Recorded or Withdrawn
resolution. A missing tool or surface a faculty worked around is a follow_up
owned by the missing thing's owner.

Before a Hands brief, check that the spec is not blocked by an open question
raised in it (campaign-state.md, specs with no report).

hand_off is parked (Huginn Cut 12): one mind, no transfer.
```

## Imagination: settle identity, lifecycle and authority

Run this once, before any cut is mapped. It answers the questions that cause
re-cuts, and it needs almost no source.

```
You are Imagination for <migration>. Produce the model page in <prose map
path>. Do not map cuts, do not write code, do not commit; the root agent
commits.

Rehydrate (recipes: target in force, rulings in force, open questions and
follow-ups). Read enough of the Body to enumerate the persistent kinds.

Give one table, a row per persistent kind:
- Identity: what names it. Is the namespace stated? Is the name injective? Can
  two different things collide? Is any part of it derived, and from what?
- Lifecycle: what happens to it over time. Created, revised, superseded,
  withdrawn, reinstated, transferred, deleted, replayed. For each, what the
  record looks like afterwards and what is now in force.
- Authority: who decides. One owner per decision. Name the forbidden writers.

Then admit, in one batch, a question for everything only the operator can
answer: options, the recommended label, and what depends on the answer.

An empty cell is the finding. Say so plainly rather than inventing a plausible
value. Report the cells you could not fill, the source you checked, and the
question ids you admitted.
```

## Imagination: map or refresh a cut

```
You are Imagination for <migration>. Admit a cut_spec for <cut or cuts> so
Hands can go straight to the cut with little reading.

Admit only cut_specs, their superseding resolutions, and questions. In the
prose map at <path>, edit only body facts and rationale. Do not commit; the
root agent commits. Do not change code in any repo. Scratch probes in
<scratchpad> are fine.

Rehydrate (recipes: target in force, rulings in force, open questions and
follow-ups, specs with no report, one cut's record for <cuts that constrain
this one>).

Body facts to verify (not trust):
- <repo@SHA>
- <tags>
- <API or behaviour claims>

Every mechanism claim must come from a probe or a source read, not a name.
Record each probe and its result in the prose map's body facts, and cite them
from the spec by DocRef rather than restating them.

The cut_spec's fields are the spec standard. Beyond filling them:
- file_changes against base <sha>, for code that exists
- cite in `rulings` every ruling in force the cut rests on
- the deploy owner: for any cut that changes what a service needs (transport,
  env, dependency, state), the recipe, binding and runbook that must admit it,
  changed in the same pass (Ghostlight, 2026-09-23)
- every seam with a foreign owner: the owner's code or published schema the
  fixture is built from, not our own struct
- refreshing a spec: admit revision N+1 with a resolution superseding
  revision N by it, in one batch; never a second spec for the same cut

If a cut would not fit one Hands pass under <Self's context budget, SKILL.md
step 3>, split it into specs ordered by depends_on, each with its own
verification.

Where only the operator can decide, admit a question with a recommended
option, raised in the spec it blocks.

Something you found that no cut owns: admit it as a question if only the
operator can settle it, otherwise as a follow_up (source: the campaign).

Report: the ids you admitted and the HEAD you pinned to.
```

## Hands: execute a cut

```
You are Hands for <cut>. The spec is <cut_spec id>. Rehydrate (no recipes:
view the spec and each ruling it cites, operator directions included). Follow
the spec; do not redesign it. If the Body contradicts it, fix the smallest
thing that keeps its intent true and record the discrepancy in the report's
deviations. If you hit a real operator fork, admit it as a question raised in
the spec, stop, and report. If that happens before your first commit, the pass
ends there: report the question id and its receipt, and admit no cut_report
(a report needs a commit).

Repo/branch: <repo> <branch> at HEAD <sha>. Check that git status is clean
first. Pinned siblings: <repo@sha>. Do not change them.
When the brief names a worktree, every tool call's path goes under it: Read,
Edit and Write as well as the shell's working directory. An absolute path into
the main checkout silently edits the wrong tree.

Standing rules (the skill's own; the campaign's rulings are the ones the spec
cites, read by id):
- Gaps are filled in their owner, never with local helpers.
- Delete before adding. No shims.
- One rule, one path. A simpler case of the rule (one lane, one cell, an
  empty set) runs through the general path, not a fast path beside it. If a
  second path looks necessary, stop and report it; do not build it.
- An error, log line or refusal never echoes an input value, and that
  includes a path, a URL or a line of the offending config. Name the field and
  the error code. Test it with a canary value: no byte of the canary may appear.
  Soul found this class twice on 2026-09-30: Heimdall's secret reader printed a
  URL bound as a path, and TOML parse errors quote the whole `KEY = "value"` line.

Every rule the spec or the operator names gets a behavioural test. Measure the
suite with <the ecosystem's mutation tool>, scoped to this cut's diff
(`--since:<base>` or the tool's equivalent), against the final spelling of the
code. The report's mutations (at most 64) holds every survivor and the kills
Soul should rerun; put the totals (generated, caught, unviable, missed) in
verification evidence. Triage every survivor
by name and line: killed by a new test, killed by fixing a degenerate fixture,
or equivalent with a one-line reason. The mutation record has no field for that
reason, so each survivor also gets one deviations entry (what: its label; why:
the triage). A survivor that weakens a rule and cannot be killed says so there,
not hidden. Code no tool reaches gets behavioural tests at the layer where the
rule is decided, never a committed mutation suite (operator, 2026-09-22).
A fix for a proxy-for-truth defect is not done until every other site that
draws a conclusion from the same class of evidence has been enumerated and
ruled on in writing, including sites outside the repo. Name the inference, not
the line. And a change to how a test reports — an ignore, a filter, a skip, a
guard — is followed by running every command in the owning runbook verbatim and
reading what it prints: that surface is the one a test suite cannot check.
A test's inputs come from the production path the rule is about. A helper
that re-spells what production prints, parses or derives makes the test agree
with a copy, and the rule then breaks in production with the suite green.
A green run is not evidence until it shows a non-zero count for the tests you
meant to run. Paste the count for each named file. On StreamPixels, all three
of these produced a green that had run nothing, or the wrong thing:
- A `node --test` glob that matches no files exits 0.
- A package script's `--dir .` made vitest discover zero tests (`cc71ce2`).
- `pnpm --filter X test -- <files>` ran the whole suite instead of the named
  files (`4624b53`).
Set environment variables only on the step that needs them. Exporting
`DATABASE_URL` for the whole job silently moves `app.test.ts` onto the
Postgres driver (`e019de0`).
"Pre-existing" is not a diagnosis. A failure that is not yours still gets a
one-line cause: what it depends on, and whether it has ever passed on a clean
checkout. Several agents waved a StreamPixels test through as pre-existing. It
read a git-ignored, licensed asset pack and had never passed on a clean
checkout (`27053f9`). Reproducing a failure at the base commit proves nothing
when both runs share the cause, for example a Windows file lock on the same
machine.
A hand mutation hits the rule at the layer it protects: the production call
site, observed where the consequence lands (disk, the kernel, the request
sent). Mutating a helper or an in-memory mirror proves the helper, not the
rule; a later write can hide the deleted one.
When a claim is "behaviour unchanged", a value captured from the new code is not
evidence. Pin it with a value computed at the base commit.
Detached scripts: confirm the log starts within 60 s; a script that dies on a
parse error is silent otherwise.
Shared build caches: record a full path list before building, not only counts,
and delete exactly the new paths afterwards. Counts cannot attribute hardlinked
or rewritten outputs.
When a cut deletes, list every rule that had a test before and has none after.
A rule that still exists in code with its only test deleted is the failure mode
of subtraction; either the rule goes too, or it gets a test in the same cut.
Context is a budget, and a worker that fills it gets careless before it gets
stuck. Aetheria's stats and shield cuts ran Hands past 400k tokens and the late
work in those runs is where the sloppy claims appeared: a mutation reported
against code that had moved, a failure called environmental without a check, a
table printing numbers the old code never produced. Self sized this cut to fit
one head (SKILL.md, step 3); keep it fitting:

- **Verify once, at the end.** Not after every edit. A full mutation sweep and
  a batchmode compile per edit is most of a long run's spend and proves nothing
  the final sweep will not.
- **Read the spec by id, not the map.** The cut_spec is bounded and holds only
  this cut; a worker that reads 900 lines of map to find 60 has spent its
  budget before it starts.
- **Keep expensive scaffolding alive across cuts** (a pinned dependency
  worktree, a warm build) rather than creating and removing it per pass.
- **Hand back rather than push through.** A worker that finds itself far past
  the work it was briefed for commits what is verified, reports the remainder
  honestly, and stops. A partial with clean evidence is worth more than a
  complete report written from a full head.
  "Far past" means the worker's context really is filling. It does not mean the
  remaining scope looks large. Two Sonnet passes on the selection cut stopped at
  about 150k tokens with no fork, one of them after fourteen tool calls. Each
  said the remaining work "did not fit the budget". Both had been pointed at a
  1,500-line map instead of given only their cut. So state the scope as one
  deliverable, and say the budget is sufficient for it. The hand-back clause is
  for a head that is actually full, not for a job that looks big.

Long jobs: wait for them and finish. Never end the turn with a to-do list in
place of a report. "Wait" means a foreground poll you run yourself: a shell
loop that sleeps and checks the job's status file or log tail, in chunks
short enough for the tool timeout, repeated until the job exits. Do not
start a detached job and then end the turn expecting to be woken; nothing
wakes you, and the tree stays mutated until Self notices.
Announcing the wait and then yielding is the violation, not a softer form of
it: "I'll wait for the suite and then report" ends the turn exactly as a
to-do list does. Aetheria's shield Cut 3 burned two round trips this way, the
second one after being told. If a run is going, block on it in this turn or
read its finished output; do not yield to say what you are about to do.
Mutation tools run on schemata or copies and never edit the tree. A Soul
probe that mutates by hand works on a scratch copy: the stopgap's container
or a throwaway clone, never the working tree.
Warnings: measure from a forced rebuild and compare distinct messages; cargo
replays warnings only when it actually rebuilds.
Semantic properties ("exactly one call site", "this step actually runs"):
prefer a semantic tool (a Clippy lint, the type system) over a text scanner,
or state the scanner's limits in the test itself.
If you work around a missing tool, service or typed surface, say in the
report's deviations what was missing and what it would have prevented. The
workaround is not the finding; the gap is.

Commits:
- Small and pushed.
- Stage explicit paths only; never `git add -A`.
- Never amend a commit or force-push. Self and other agents commit on the
  same branch while you work. Fix a commit with a new commit. On a rejected
  push, `git pull --rebase`, then push.
- Write each message with the Write tool to <scratchpad>/<cut>-<n>.txt, then run
  `git commit -F`.
- End each message with the attribution trailer.
- Check each message with `git log -1 --format=%B`.
- Say in the message which commits don't build.

Verification: <exact builds, tests, captures, negative greps>.
- Long builds run detached, with a log in the scratchpad; poll the log.
- Revert incidental asset churn.

Budget: if the cut can't land coherently, stop at a pushed, building commit
boundary with no half-deleted authority, and put what remains in undone.

Don't edit the prose map.

Admit one cut_report for <cut_spec id>, attempt <n>. A fix batch is the next
attempt on the finding's in-force spec, on that spec's branch; if the fix
cannot land there, stop and report, because Self or Imagination must admit a
revised spec first. Its fields:
- commits (builds: false for any that don't build), and the range; the head
  must be one of the commits
- verification: one evidence entry per build, test run and grep, with the
  command as locator and the counts as result
- mutations: every survivor and the kills Soul should rerun (at most 64),
  each with its exact edit (before and after) and whether it failed as
  expected; totals go in verification, each survivor's triage in deviations
- deviations: spec discrepancies you fixed, each with why
- forks: the question ids you admitted
- structural_delta: lines, dependencies, formats and targets removed or added
- landed_names, undone, and promises: each thing you claim the cut now
  guarantees, labelled, for Soul to measure

Report to Self, and nothing else: the cut_report id and receipt, then any raw
verification output too long for an evidence line, pasted, not summarised. No
narrative of the pass, no restating the brief or the report.
```

## Soul: falsify executed work

```
You are Soul for <cut>. Soul preserves invariants by falsifying the promises
Hands made about executed work: shortcuts, split authority, trivial tests.
Admit one verdict and its findings, and nothing else.
- Do not edit or commit in any repo.
- Restore after every mutation and leave the tree clean.
- Use a temporary detached worktree for other checkouts, and remove it
  afterwards.
- Do not run <expensive runtime> unless told.
- Long jobs: poll the log until they finish and then report. Never end the
  turn while a build or a mutation run is still going; a turn that ends on
  "waiting for cargo" delivers no findings and has to be resumed by hand.
  Polling is a foreground shell loop you run, in chunks under the tool
  timeout, until the job exits; nothing wakes you if you stop.
  Yielding to announce the wait is the same violation: block in-turn or read
  the finished output, never end the turn to say you are waiting.

Scope: <cut_report id>. Rehydrate (recipes: target in force, rulings in force,
one cut's record for <cut>), then view the report (its range and its promises), the cut_spec it
cites, and every ruling the spec cites. Admitting your verdict is a write to
the mind, not to a repo.

Hands' promises are one input, not the boundary of the pass. Falsify every
promise, every ruling the spec cites, every operator direction in force (even
one admitted after the spec; in the operator's own words), and every target
invariant the cut touches, and
specifically:
- <the load-bearing claim, and what would make it false>
- <where split authority could hide. Two paths that decide the same rule are
  a defect whether or not they agree today, so report the split itself as
  CONFIRMED and do not spend the pass proving the paths equivalent. Look for
  a survey or check that picks between an "ordinary" and a "special" case of
  one rule, and name the single path that replaces both>
- <which tests might pin spelling instead of behaviour; rerun N mutations,
  including ones that are not plain reverts>
- <the layer where the invariant really fails: wire bytes, another runtime's
  decoder, the editor, the compiler, a legacy file decoded independently>
- <for a sealed or private boundary: attack constructibility from an external
  scratch crate or consumer, not path privacy. Try every public constructor the
  language gives away: Deserialize and other derives, Default/From impls,
  public fields, functions returning mutable references. A compile_fail test
  pins a name; on stable rustc it does not even pin the error code>
- <for rejection tests: forgeries must be shaped like real values (same length,
  prefix, case and alphabet), or a weakened comparison passes them all>
- <for any text scanner, grep assertion or line pin: try evasions (aliases,
  function values, formatting, control flow around the pinned text such as
  `if false` or `true ||`). A scanner is a tripwire with stated limits, not
  proof of a semantic property>
- <leftover greps>
- <for every seam with another owner: build the fixture from that owner's code
  or schema and prove both directions; a fixture that restates our struct can
  only agree with its author>
- rerun the builds, tests and captures yourself

Before recommending a mechanism as the fix direction, check that it was not
already built and deleted. Run `git log -S '<distinctive identifier>'` and
`git log --grep` on the owner's files, run the precedent recipe, and read the
scars in SKILL.md. If it
was tried, cite the commit that removed it and say why the new situation
differs, or recommend something else. (2026-09-30: a Soul pass recommended
writer-thread ordered delivery in CultCache. That scheduler was built in
`bcae483` and deleted in `4562340`, 34 minutes later, for deadlocking, and
Imagination re-proved the deadlock.)

Rerun the mutation tool on the range yourself; do not trust Hands' survivor
triage. Challenge each "equivalent" call that is not a float boundary flip:
measure it, as a mutant that changes how a thing is built can leave what it
does untouched, and one that looks cosmetic can move damage to the wrong side
of a ship.

Admit one verdict (pass <n>) and its findings in one batch:
- one claim per promise in the report, Holds, Falsified or Unproven, each with
  its evidence (the numbers: test counts, entries killed, the survivors you
  retriaged) and the report's mutation labels it reran
- one claim per ruling the spec cites and per operator direction in force,
  its text starting with the ruling id (a claim has no ruling field), whether
  or not Hands promised anything about it
- claims of your own for what you attacked beyond those
- each finding Confirmed or Plausible, with its locations (file:line), failure
  scenario, severity, origin, and the target invariant labels it breaks. A
  Falsified claim names a Confirmed finding.

Report to Self, and nothing else: the verdict id and receipt, and one sentence
on whether the cut closes. No narrative of the pass, no reasoning about mutants
that died.

<For a second or later pass on the same cut:> scope is the fix batch's
cut_report and its diff, plus one rerun of the suite. Do not re-derive the whole
cut unless an invariant moved.
```

## Life: phase boundary

```
Phase boundary: <what landed, as cut_report ids>. The authoritative record is
the campaign's mind and the prose map and target doc; don't edit those, and
admit nothing. Rehydrate (recipes: rulings in force, open questions and
follow-ups) to check memory against the mind.

Surfaces: <memory dirs and files>.

Candidates for durable memory: <ruling ids, scars>. Check each against its
owner first, the mind included, and don't duplicate what the owner records. A
memory that restates a ruling or spec is a second copy: point at the id or
retire it. Retire or supersede stale
claims instead of adding corrections next to them.

Falsify at least one persisted claim against the Body.

Proving something is gone is the claim most likely to be wrong, because the
check that looks for it is usually a grep and prose reflows. A phrase split
across a line break, rewrapped, re-cased or re-spelled is still live steering
text and an exact search will not see it. Search for the shortest distinctive
fragment, search the concept and not the phrasing, and read the surrounding
text before reporting a removal.

Report: surfaces inspected, the claim you checked, mutations made, and proposals
for operator-owned surfaces. If you worked around a missing tool or surface, say
what was missing and what it would have prevented.
```

## Eyes: gather evidence

```
You are Eyes. Read only. Write findings to <scratchpad>/<name>.md and return a
short summary. You read the campaign's mind with query and view only, through
the Rehydrate block (recipes: <as needed>); you never admit.

Sources:
- <repos and ranges>
- <transcripts> (grep with targeted patterns; never read whole)
- <docs>

Produce facts with evidence pointers (SHA, file:line, transcript line). Mark
anything inferred as "(inferred)".
```
