# Tool-calling cut map (Imagination, 2026-10-01)

Target: fewer model calls, and less context re-read by each call, with the
Soul loop untouched. Pinned to skill HEAD `92bf6f7`. Eyes' facts are in the
session scratchpad (`eyes-tool-calling-facts.md`). The classifier scripts are
`tc_index.py`, `tc_classify.py` and `tc_comp.py` in the same scratchpad, and
every number below can be rerun from them.

## 0. The cost model (measured)

Every model call re-reads the whole context. A subagent starts at **~70k**
tokens: about 34k shared system prompt and tools, plus about 36k written per
agent (CLAUDE.md files, brief and listings). It then grows by a nearly constant
**~1.7-1.9k tokens per call**. In the two largest Hands there was no single
jump over 15k: affba1c4 went 69k→742k over 386 calls, and a0a3154a went
70k→781k over 332. So for an agent of N calls:

    reads ≈ N·70k + 0.9k·N²

For a 390-call Hands the N² term is ~85% of its 163M. **Call count is the
lever, and it acts quadratically.** Halving a long agent's calls cuts its
reads by about 3x. Splitting it in two at the midpoint cuts them by about 40%.

The **5-minute subagent cache TTL is real.** Measured over all subagent calls
since 09-29:

| gap since previous call | calls | cache write | avg write |
|---|---|---|---|
| < 60 s | 25,232 | 56M | 2k |
| 60-300 s | 2,336 | 5M | 2k |
| **300-3600 s** | **1,241** | **292M** | **235k** |
| > 1 h | 10 | 2.5M | 249k |

79% of all subagent cache writes come from the 4% of calls that follow an idle
gap of more than 5 minutes. Each of those rewrites the agent's whole context at
1.25x the base price, where a cache read costs 0.05-0.1x. The quota weighting
of reads against writes on a subscription is unpublished, and Eyes flagged it
as open. In API-price terms, these rewrites are roughly a third of subagent
input cost.

## 1. Waste taxonomy (measured, 09-29 → 10-01)

### Self (root), 09-29/30, deduplicated by message id
- 2,135 model calls, 984M context read, median context about 500k, peak 924k.
- **1,703 of the 2,135 calls (80%) emitted no tool call.** 1,035 of them had
  no text at all: Self woke up, read about 500k, and ended the turn.
- 1,324 text-only calls followed a task notification. They cost **596M, 61% of
  root reads.**
- Root received 602 "Agent … finished" notifications from **245** agents.
  **68 agents finished more than once**, giving 357 interim notifications: one
  Hands 29 times, two Souls 21 times each. Docs: a background subagent's
  results reach Claude "as a completion notification", and a subagent's own
  background command notifies the subagent when it ends. Measured: every
  interim turn end of a subagent reached the root as a finished notification.
  **The pattern in `92bf6f7` ("end the turn with the waiter running and say
  nothing") is exactly this pattern.** It moves the wait's cost from the
  subagent (~200k context) to Self (~500-900k).
- Agent results pasted into root: median 203 chars, p90 7.7k chars, about 404k
  tokens over two days. The p90 is the "raw verification output, pasted"
  clause in the Hands report.

### Hands: 167 agents, 16,863 calls, 3.79B read

| class | calls | share of reads | what it is |
|---|---|---|---|
| search (Bash grep/find/rg) | 21.2% | 19.0% | Mostly legitimate orientation. Avg result 700 tok. |
| **wait.poll** (foreground `until/for … sleep`) | **11.5%** | **14.9%** | e.g. `for i in 1..18; do grep …; sleep 20; done; tail -60`, repeated per job |
| **verify.read_log** (tail/cat/grep a job log) | **9.0%** | **10.2%** | reading raw logs after or between polls |
| read.file | 12.3% | 9.9% | avg 1.9k tok per result, the largest growth source |
| edit (Edit/Write) | 9.4% | 10.2% | necessary |
| verify.launch | 8.6% | 8.6% | 8.6 jobs per agent, often one per probe or mutant |
| git.read | 9.3% | 7.9% | status, log, diff, show |
| **edit.script** (python heredoc editors) | **6.5%** | **7.3%** | each agent re-invents a CRLF/BOM-preserving `def edit(p,f)`; its inputs were the largest context item in 3 of 5 heavy Hands (39-56k tok) |
| git.write | 2.4% | 2.5% | add/commit/push, plus Write for the message file and a `git log -1` check |
| wait.monitor + wait.stop + ssh.inspect | 3.8% | 4.1% | Monitor arms, TaskStop, ssh docker/ls checks |

- Waiting and observing (poll, read_log, monitor, stop) took **3,852 calls
  against 1,443 launches: 2.7 observation calls per job.**
- Exact duplicate calls: 1,564 (9.3%), mostly re-polls.
- **Ad-hoc harnesses were reinvented per agent:** `runmut.sh`, `runprobe.sh`,
  `harness.sh`, `fulljob.sh`, `mutjob.sh`, `mutrun.sh`, `strykrun.sh` and
  `scriptrun.sh` appear across the sampled Hands and Souls. They are the same
  three jobs (verify, mutate, probe), written fresh each time.

### Soul: 146 agents, 8,752 calls, 1.40B read
- search 23.4%, **git.read 21.2%** (avg result 1.1k: the range diff re-read
  piecemeal), read.file 12.4%.
- Waiting and observing: wait.poll 9.3%, read_log 9.3%, monitor and stop 1.9%.
  That is **1,800 observation calls against 813 launches (2.2 per job).**
- Sampled Soul aba0348c: 163 calls, 6 `mutrun.sh` and 5 `strykrun.sh`
  launches, each followed by its own poll and read cycle.

### Imagination: 25 agents, 2,130 calls (85 each), 431M read
- search 28.5%, git.read 24.5%, read.file 18.6%. Orientation by single shell
  calls, where probe scripts would do the same work in fewer calls.

### Baseline prefix
- The global `~/.claude/CLAUDE.md` is 56k chars and `F:\Projects\CLAUDE.md` is
  14k chars, about 17.5k tokens together. Both load into every subagent.
- Over about 28.8k subagent calls since 09-29 that is about 500M re-read, about
  9% of subagent cache reads.

## 2. Target call shape per faculty

These are the target numbers per faculty. "Script per phase" means one Bash
call that runs a written script and prints a bounded result. It replaces
chained single commands.

| faculty | calls | peak ctx | phases (one script or one parallel batch each) | lifetime |
|---|---|---|---|---|
| **Self** | ≤ 3 per dispatched agent (dispatch, read the final notification, triage) | **≤ 300k**, rotate past it | rehydrate is one recipe batch; triage is parallel `view`s | rotates at phase boundaries (§4) |
| **Imagination** | 40-80 | ≤ 250k | (1) an orient script that dumps `git log`, file:line excerpts and grep hits to a scratch file and prints ≤ 150 lines; (2) probe scripts, one per question, each run in one verify job; (3) one admit batch | one map pass per agent; a refresh is a new agent |
| **Hands** | **60-150** | **≤ 300k** | (1) an orient script: status, base, spec `view`, and `sed -n` excerpts of the spec's anchors in one call; (2) edits through Edit, with independent edits in one parallel message; (3) **one verify job** (build, scoped tests, mutation) through `ygg-verify` summary mode, waited in the foreground (§3a); (4) **one commit call** per commit; (5) the report admit | **hand off at ~300k** or ~150 calls: commit what is verified, admit the `cut_report` with `undone`, stop. Self dispatches a continuation |
| **Soul** | 50-120 | ≤ 300k | (1) dump the range once: `git diff base..head > $S/range.diff` plus `--stat`, then grep that file instead of re-running `git show` per file; (2) **one probe job** carrying all probes, the hand mutants as a list (§3b) and the scoped reruns; (3) **one final job**: full suite plus the mutation tool; (4) the verdict admit | a second pass covers only the fix delta (already ruled) |
| **Eyes** | ≤ 40 | ≤ 200k | parallel WebFetch and search batches; transcript work as scripts, never whole reads | one question set per agent |
| **Life** | ≤ 25 | ≤ 150k | one inventory script over the surfaces, then the edits | per phase boundary |

Rules common to every faculty:
- **Observation bounds.** No command prints more than ~150 lines. Logs go to a
  file. You read `tail -n 60`, or `grep -n` hits with `-m`. You never `cat` a
  whole log or source file over ~300 lines; read the anchor's range instead.
  Reading in 100-line windows matches the SWE-agent ablation (18.0% against
  12.7% for full-file views). Reading a file twice is a smell. Write what you
  need to keep to a scratch notes file instead.
- **Parallel tool calls.** Independent reads, views and greps go in one
  message. This saves wall time and turns, not reads.
- **No turn ends before the report.** A subagent's turn end is a paid wake of
  Self (§1).

## 3. Tooling ledger, and the shared script body

Code is a liability, so deletions come first:
- Delete the `git log -1 --format=%B` check (briefs.md 305).
- Delete "poll the log" (briefs.md 309).
- Delete "Run long builds detached … and poll" for agents (SKILL.md 577-579).
- Delete the raw-output paste in the Hands report (briefs.md 334-336).
- Delete the per-agent harness reinvention, by replacing it with the shared
  scripts below.

| tool | owner | consumer | calls saved (from the taxonomy) | carrying cost |
|---|---|---|---|---|
| **(a) `ygg-verify` summary mode + foreground waiter.** `SUMMARY=1` keeps the full log in a file and prints a bounded summary: exit verdict, pass/fail/skip counts per test binary (and a `ZERO TESTS RAN` line when the count is 0), failing test names, and the last 30 lines of each failure, capped at ~80 lines. The companion `wait` mode blocks ≤ 270 s per call on a done-file and prints `RUNNING <elapsed>` or the summary. | the stopgap's owner (the skill repo). It dies with the stopgap when Idunn's typed verify verdict lands, and must not outlive the deletion line in `ygg-verify.sh` | Hands, Soul, Imagination probes | Observation calls fall from 2.7 to ~1-2 per job: about **−2,400 Hands and −1,000 Soul calls per two days, ~13% of calls.** Because of N², that is ~15-20% of reads | ~60 lines of bash plus a parser per ecosystem (cargo test, dotnet test, vitest, pytest). **Verdict-bearing**: a summarizer that drops a failure forges a green. It gets a Soul pass before merge, plus a fixture test per parser: a failing run, a zero-test run, a killed run and a no-verdict run |
| **(b) mutation runner.** It takes the ecosystem tool's diff scope, *or* a list of hand mutants (`file`, `before`, `after`, `tests`), and returns a kill table (label, outcome, killing test) in one job. Hand mutants are applied in the container clone, so the tree is never touched | same | Soul primarily, Hands for the scoped run | Replaces the reinvented `mutrun`/`strykrun`/`runmut` scripts. One job instead of one per mutant: in aba0348c, 11 launches with their wait/read pairs become ~2. **Estimate (inferred): −20-40 calls per Soul pass** | ~100 lines. **Verdict-bearing**: same Soul and fixture rule. It must report `unviable` and `timeout` separately from `caught` (the brief's totals already require this) |
| **(c) commit helper.** **Not built.** In Git Bash, `git add <paths> && git commit -F- <<'MSG' … MSG && git push` is one call. The BOM and here-string scar is PowerShell-only (SKILL.md 568-571) | — | Hands, Self | ~1.5 calls per commit, ~1.5% of Hands calls, at **zero code** | none. A brief and SKILL text change only |
| **(d) CRLF/BOM-preserving edit.** **Probe first**: does Edit preserve CRLF and BOM on these repos? If yes, the brief says "use Edit; no python editors" and nothing is built. If no, one shared `edit.py` replaces 1,097 reinvented editors | probe: Self, now | Hands | 6.5% of Hands calls, and the largest tool-input context item | zero if the probe passes, ~30 lines if not |
| (e) an orient script per faculty | — | — | not a shared tool: one line in each brief ("orient in one script") | none |

### 3x. The shared script body (operator: "Is that too ambitious?")

**Direct answer: no, provided it stays a directory in a git repo with ordinary
review.** It is small and it already exists: `tools/stopgap/` in the skill
repo. What the data shows is the opposite problem. Every Hands and Soul writes
its own `runmut.sh` or python editor and throws it away, and that costs calls
and context in every pass. The ambitious part would be a bespoke admission
process, and per the operator's follow-up none is needed: collaborating on code
is a solved problem.

**Facts (gamecult-ops):**
- Forgejo 16.0.3 runs on Yggdrasil at `127.0.0.1:3300` behind nginx as
  `git.erycina.org`.
- Its purpose is "public, anonymously readable source hosting for Erycina".
  The inventory says Erycina is "not a GameCult subdomain by intent … meant to
  read as creator-owned and separately stewarded".
- Actions are **deliberately not enabled**: "CI runners on the same host as the
  state store … Revisit when there is something to run".
- Registration is disabled, and accounts are created by an admin through the
  forgejo CLI.
- Git runs over SSH through the host `sshd` as the `git` user, with keys
  registered in Forgejo. Agents would authenticate with an SSH key registered
  to a dedicated bot account (for push) and a Forgejo API token held outside
  briefs (for PRs). No secret appears in any brief or in this map.
- No mirroring is documented. Forgejo supports push mirrors natively.
- As of 09-05 TLS was staged pending DNS. Whether it is issued now is unverified.
- The skill repo's `origin` today is `github.com/GameCult/Eureka`.

**Shape (recommended, pending Q4):**
- **Where it lives:** in the skill repo itself, in `tools/`, with the stopgap
  staying under `tools/stopgap/`. It does not go in a separate repo. Scripts
  and briefs change together, since a brief names a script's flags, so one
  revision pins both. Agents already have the checkout at
  `~/.claude/skills/eureka`, so there is no clone path to manage and nothing
  separate to pin. Self records the skill SHA in the campaign's first brief
  line, which pins it for the run.
- **Contribution:** an agent that writes a reusable script pushes a branch
  `tools/<name>` and opens a PR. It never pushes to `main`. The PR carries the
  script, its fixture test, and one line of evidence: which calls it replaces
  (a transcript count from `tc_classify.py` or a named pass) and its live
  consumer, the brief line that will call it. **A PR without a consumer line is
  not merged.**
- **Admission = merge.** Self merges convenience scripts. Scripts whose output
  a verdict depends on (the summarizer, the mutation runner, the waiter) are
  cuts: a Soul pass on the PR comes before the merge, by the same rule as "a
  release is a cut". Without Actions, the fixture tests run through
  `ygg-verify` on the PR head, and the reviewer pastes the summary line into
  the PR. Forgejo PR review is the record.
- **Discovery:** a `tools/INDEX.md` with one line per script (name, purpose,
  consuming brief section). Briefs name the exact script they want. Agents do
  not browse.
- **Pruning:** an `INDEX` line whose consuming brief no longer names the script
  marks it dead, and the next Self pass deletes it. Stopgap scripts keep their
  DELETION LINE header. Life does not touch scripts (they are Body); at a phase
  boundary it may report an INDEX entry with no consumer.
- **What stays out:** anything that knows a project's layout (CultLib crate
  paths, Aetheria test names, a cut's mutant list). That goes in the project,
  or in the job's argument.

## 4. Self's lifecycle

What Claude Code supports, per the docs fetched 10-01:
- `/clear` "costs nothing" and starts fresh. It is an operator command. Self
  cannot run it on itself.
- Auto-compaction triggers near the auto-compact window.
  `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` sets the threshold and "applies to
  subagents as well". Compaction "is itself a large request".
- The main-conversation cache lifetime is 1 h on a subscription and drops to
  5 min once usage credits are drawn. The 5-minute subagent TTL is measured
  above, not documented on that page.
- The env var `CLAUDE_CODE_SUBAGENT_PROMPT_CACHE_TTL` comes only from a
  third-party repo (Eyes). **It is unverified.**
- **API-only:** the context-editing and memory tools, programmatic tool
  calling, and the tool-search tool. Claude Code applies its own tool-result
  clearing and compaction. Self cannot call these.

Shape:
1. **No interim wakes.** Subagents never end a turn before their report (§2,
   §3a). This removes the 357 interim notifications, worth about 600 root calls
   at ~500k, which is **~30% of root reads**.
2. **Rotate the root at about 300k, or at each phase boundary, whichever comes
   first.** All campaign state is in Huginn, so the handoff is short: the
   campaign slug, the session label, in-flight agent ids, and the next action,
   written to the scratchpad. Self then asks the operator to `/clear` (Q3). A
   fresh root rehydrates with the campaign recipes, at about 100k. At a median
   root context of ~200k instead of ~500k, **every remaining root call costs
   about 60% less**.
3. **Reports stay id-only.** Hands and Soul return an id, a receipt and one
   sentence. Long raw output goes to a scratch file, and the report gives its
   path.
4. **Self delegates reading.** It never reads a log or a diff itself. It reads
   the verdict and the report by `view`.
5. Backstop: if the operator prefers it, a lower auto-compact threshold (Q3)
   stops a forgotten rotation from riding to 900k.

## 5. Text changes (anchors at skill HEAD `92bf6f7`)

### `references/briefs.md`
- **275-283 (Hands "Long jobs" paragraph): replace with:**
  > Long jobs: wait for them and finish, and never end your turn before your
  > report. Each turn end reaches Self as a notification and costs a read of
  > its whole context. Start the job as one background shell whose command
  > exits only when the job does. Then wait in the **foreground** with
  > `ygg-verify.sh wait <done-file>` (or `until [ -e <done> ]; do sleep 60;
  > done` with a 270 s cap), one call at a time, each ≤ 270 s so that your
  > cache stays warm. A call longer than 5 minutes rewrites your whole context.
  > Never run a second watcher on the same job, no timer shorter than 60 s, and
  > no interim message.
  (Pending Q1. If the operator picks B, keep the current text and add only
  the 270 s cap.)
- **309: delete** "Long builds run detached, with a log in the scratchpad;
  poll the log." Replace it with: "Verify through `ygg-verify.sh` with
  `SUMMARY=1`; read the summary, and open the full log only at a named failing
  test, with `grep -n -A 40`."
- **255-257 ("Verify once, at the end"): append** "One job carries build,
  scoped tests and the mutation run (briefs Soul, 390-399)."
- **248-273 (context budget block): add three bullets:**
  - **Orient in one script.** One Bash call prints git status, base and the
    spec's anchor ranges (`sed -n`) for every file the spec names. Independent
    reads go in one parallel message.
  - **Bound every observation:** ≤ 150 lines per command; logs go to files;
    read windows, not whole files.
  - **Hand off at ~300k context or ~150 calls.** Commit what is verified,
    admit the `cut_report` with `undone`, and stop. Self dispatches a
    continuation with the report id. This replaces the "far past" judgment at
    263-273 with a measurable line. Keep the clause's warning against stopping
    because the scope looks large.
- **296-306 (Commits): replace** the Write-tool and `git log -1` bullets with:
  "In Git Bash, one call: `git add <paths> && git commit -F- <<'MSG' … MSG &&
  git push`. Never commit from PowerShell (it writes a BOM and breaks
  here-strings)."
- **334-336 (Hands report): replace** "then any raw verification output too
  long for an evidence line, pasted, not summarised" with "and, for output too
  long for an evidence line, the scratch path that holds it".
- **350-353 (Soul long jobs): same replacement as 275-283.**
- **390-399 (Soul reruns): append** "Dump the range once (`git diff
  <base>..<head> > <scratch>/range.diff` plus `--stat`) and grep that file.
  Hand mutants go in one list to the mutation runner, never one job each."
- **428-430:** unchanged. It is already id-only.
- **117-163 (Imagination map) and 91-112 (0b): add** "Orient and probe through
  scripts: one call per question, output ≤ 150 lines."
- **469-480 (Eyes): add** "Budget ≤ 40 calls; transcripts by script; batch
  fetches in parallel."
- **439-465 (Life): add** "Budget ≤ 25 calls; inventory the surfaces in one
  script."

### `SKILL.md`
- **215-236 (sizing): add** after 219: "Size by calls too. Each call re-reads
  the context, so an agent's reads grow with the square of its calls (measured
  ≈ 70k·N + 0.9k·N²). A cut that needs more than ~150 Hands calls is two cuts,
  or one cut and a continuation."
- **451-513 (Self's discipline): add two bullets:**
  - **Self's own context is the most expensive in the pipeline.** Every
    notification re-reads all of it. Rotate at ~300k or at a phase boundary:
    write the handoff (slug, session label, in-flight agent ids, next action)
    and ask the operator to `/clear` (ruling: Q3). Never read logs or diffs in
    the root; `view` reports and verdicts.
  - **A subagent that notifies before its report is a brief defect.** Count
    finished notifications per agent. More than one means a turn ended
    mid-wait, and the brief template is what gets fixed.
- **537-552 (Yggdrasil):** the line says "at most 3 jobs at a time" and "12
  GiB". The script says `SLOTS=5` and `MEM=6g`. **This is stale again.** Drop
  the numbers and point at the script, as the line itself demands.
- **568-571 (commit messages): replace** with "Commit from Git Bash with
  `git commit -F- <<'MSG'`. PowerShell 5 here-strings break `-m`, and its
  `Out-File`/`Set-Content` write a BOM."
- **577-579 ("Run long builds detached … and poll"): split.** Operator-side
  builds (Unity batchmode) stay detached, with a log and a PID. Agents wait in
  the foreground in ≤ 270 s calls (briefs Hands).
- **New short section after 513, "Shared tools":** the `tools/` body, `INDEX.md`,
  the PR-as-admission rule, Soul before merge for verdict-bearing scripts, and
  pruning by consumer (§3x).

### `references/changelog.md`
- New top entry: "Waiting costs no wakes". Evidence: 602 finish notifications
  from 245 agents, 1,324 root text-only calls, 596M, and the 5-minute TTL table.
  It amends `92bf6f7`.

## 6. Operator questions

**Q1. How does a subagent wait?** (It amends `92bf6f7`, landed today.)
- A. Foreground calls of ≤ 270 s on a done-file, about one call per 4.5
  minutes. The cache stays warm and Self is never woken. **Recommended.**
  Per 10 minutes of waiting it costs about 2.2 cache reads, ≈ 0.2 context
  units, against 1.25 for one rewrite. Timers inside the call are ≥ 60 s, per
  the operator's floor.
- B. Keep the background waiter and the turn end (current). Measured: 357
  interim root wakes in two days at ~500k each, plus a 235k cache rewrite per
  resume after 5 minutes.
- C. Foreground calls of up to 10 minutes. Fewest calls, but each one is a
  full rewrite. Pick C only if Q2 lands the 1 h TTL.

Depends on it: the briefs' long-jobs text and the waiter mode of
`ygg-verify.sh`.

**Q2. Probe the subagent 1 h cache TTL?** `CLAUDE_CODE_SUBAGENT_PROMPT_CACHE_TTL=1h`
is unverified, from a third party. It doubles each write's price, and in
exchange idle gaps up to 1 h stop forcing rewrites (292M of rewrites in two
days).
- A. Self runs one bounded probe: set the variable, run a subagent with a
  7-minute gap, and check `cache_creation` on the next call. Then decide.
  **Recommended.** Settings are yours, so this needs a go.
- B. Leave it alone.

**Q3. How does Self's context get reset?**
- A. Self writes a handoff and asks you to `/clear` at about 300k or at a
  phase boundary.
- B. Set `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` so that auto-compaction fires around
  300k.
- C. Both: A by default, B as the backstop. **Recommended.**

Depends on it: Self's discipline text. The root stayed at a median of ~500k
for two days.

**Q4. Where does the shared script body live?**
- A. In the skill repo's `tools/`, on GitHub `GameCult/Eureka`, with PRs there.
  This costs zero setup.
- B. The skill repo moves to Forgejo, primary, with a push mirror to GitHub.
  Review happens on Forgejo, beside where the scripts run. This means a GameCult
  org on a forge documented as Erycina's, "separately stewarded" and with a
  landing page fixed to Erycina, plus a bot account and key.
- C. A separate scripts repo on Forgejo, pinned by the skill. That adds a
  second checkout and a pin, for nothing the skill repo cannot carry.

**Recommended: B if you are content to put GameCult tooling on the Erycina
forge, otherwise A.** The workflow is identical either way: branch, PR, merge
as admission. Forgejo Actions stays off (the runbook's choice), and tests run
through `ygg-verify`.

**Q5. Slim the always-loaded doctrine?** The two CLAUDE.md files are about
17.5k tokens in every subagent, about 9% of subagent cache reads. Claude Code's
docs advise keeping CLAUDE.md "under 200 lines" and moving workflow-specific
text into skills.
- A. Move the long-form Cult, Praxis and Infrastructure sections into a
  referenced file. The Prime Directive, Code Is A Liability, the rebuild
  contract and the faculty lines stay inline. **Recommended.**
- B. Leave it.

It is your text; this is a question, not a cut.

## 7. Measured versus inferred

**Measured** (scripts in the scratchpad, rerunnable):
- the per-faculty class distributions;
- the 2.7 and 2.2 observation calls per job;
- the duplicate counts;
- the reinvented-harness names;
- the root call profile, its text-only share and the notification counts per
  agent;
- the context growth per call;
- the 70k baseline;
- the cache-write-by-gap table;
- the CLAUDE.md sizes;
- the Forgejo facts (gamecult-ops);
- the stale slot and memory numbers in SKILL.md.

**From docs (fetched 10-01):**
- `/clear`, compaction and `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` reaching
  subagents;
- the main-cache TTL;
- the background-command notification;
- the PreToolUse filter;
- the CLAUDE.md advice.

**Inferred:**
- That each interim subagent turn end produces a root notification. This is
  consistent with the counts and the docs, but no single event was traced.
- The per-tool savings estimates, and the calls saved by the mutation runner.
- The 300k and 150-call handoff lines. They are chosen from the N² model and
  the 400k "loopy" scar, not tuned.
- The quota weight of cache reads against writes. It is unpublished, so the
  savings are stated in reads and writes, not in quota.

**Classifier limits:** Bash commands are classified by regex on mixed command
lines, so a compound call counts once, under its first matching class. Before
reordering, the "verify.launch" class absorbed poll loops that grep for
"ygg-verify:" in logs. The tables above are from the corrected ordering.
Parallelism was not measured.

## 8. Rulings (operator, 2026-10-01)
Verbatim: "Q1 A, Q2 yes, Q3 agreed, Q4 B, Q5 yes, but see Epiphany's approach where each subagent gets its own targeted philosophy centered on its role".
- Q1 = A: subagents wait in the foreground, in calls of at most 270 s, and never end a turn before their report. This supersedes `92bf6f7`.
- Q2 = A: Self runs one bounded probe of `CLAUDE_CODE_SUBAGENT_PROMPT_CACHE_TTL=1h`.
- Q3 = C: rotate at about 300k or at a phase boundary, with a handoff and the operator's `/clear`. A lower `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` is the backstop.
- Q4 = B: the shared scripts stay in the skill repo on GitHub (`tools/`, `tools/INDEX.md`), contributed by branch and pull request.
- Q5 = yes: slim the global CLAUDE.md along Epiphany's per-role philosophy. A separate Imagination pass maps it.
