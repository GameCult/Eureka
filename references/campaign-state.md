# Campaign state

A campaign keeps its state in two places, and nothing lives in both.

- **The mind.** Questions, rulings, cut specs, reports, verdicts, findings,
  follow-ups and resolutions are typed documents in the instance's mind, held by
  Huginn and reached through the `eureka-state` MCP tools. Status is derived
  from them on every read; nobody writes it.
- **The prose.** A target document and a map document, committed in the repo
  the campaign changes. They keep only what no kind carries: body facts (probes
  and their results), the model page (step 0b), and rationale. The typed
  `target` points at the target document through `target.doc`.

The shapes below are the leaf's (`epiphany-pipeline`, pinned by Huginn) and the
organ's (`huginn-mind`). Where this page and the tools' own schemas disagree,
the tools are right and this page is stale.

## The tools

The instance and the daemon are the server's configuration
(`EUREKA_INSTANCE`, `HUGINN_ENDPOINT`), never an argument.

| Tool | Input | Answer |
|---|---|---|
| `whoami` | `{}` | `{ instance, endpoint, reachable, status }`. `status` is `{ instance, schema_epoch, documents, receipts, index }`, and `index` is `Current`, `Reconciling`, `Behind`, `Failing` or `Refused`. When unreachable, `error` says why. |
| `admit` | `{ faculty, agent, session, documents }` | `Committed { receipt_id, committed_at, writes }`, `AlreadyAdmitted { receipt_id }`, `Conflict { identities }` or `Refused(<refusal>)`. One to 64 documents, admitted whole or not at all. |
| `view` | `{ id: { kind, id } }` | `{ id, document, admission, status }`, or `null`. |
| `query` | `{ selection, semantic? }` | `{ matched, as_of, next, items, edges }`. `items` is `Headers([...])` or `Documents([...])`. |

- `faculty` is one of `SelfFaculty`, `Imagination`, `Hands`, `Soul`,
  `Life`, `Eyes`, `Operator`. It is attribution, not authority.
- `agent` names the admitting agent. `session` is the campaign session label
  Self gives in every brief, so that sessions sharing one mind stay tellable
  apart.
- A document on the wire is `{ "kind": "<kind>", "value": { ... } }`, with the
  kind in snake case (`cut_spec`). A reference is `{ "kind": "<Kind>", "id":
  "<full id>" }`, with the kind in Pascal case (`CutSpec`).
- **A refusal is an answer.** It names the rule, for example
  `CitesResolvedDocument`, `ResolutionOutOfSequence` or
  `PromiseWithoutVerdict`. Fix the batch and admit again. An exact replay
  answers `AlreadyAdmitted`, so retrying a batch is safe. A key, format or
  bound error arrives as `Refused(Document(..))` with the field and value:
  fix it and resend. `Refused(Unavailable)` means a store fault: retry once,
  as for `isError` `Unavailable`. The retired faculty name for `Life` is
  refused in query selections; stored receipts that carry it still decode.
- **`isError: true` means no answer:** `Unavailable` (the daemon is down or
  unreachable), `Rejected` (it refused the envelope), `Misconfigured`,
  `TooLarge`, `Unencodable`, `InvalidInput` or `Internal`.

### When the organ does not answer

This is the one rule for every faculty.

1. **The tools are missing** from the session's tool surface: stop and tell the
   operator (a subagent tells Self). A server registered after the session
   started appears only in a new session. Never fall back to prose.
2. **`Unavailable`:** retry the same call once. A cold semantic embed after an
   idle spell took over 15 s live, which is the client's whole timeout.
   Retrying `admit` is safe, because an exact replay answers `AlreadyAdmitted`.
3. **`InvalidInput` or `TooLarge`:** the call is wrong, not the organ. Fix it
   (the arguments, or a narrower selection or smaller batch) and retry, as for
   a refusal.
4. **`Unavailable` after the retry, or any other `isError`:** stop. A subagent reports the
   error and the step it stopped at, and stays resumable: Self continues it
   with `SendMessage` once `whoami` answers. Never send the record to Self as
   prose, and never keep it anywhere else meanwhile. The mind is the only
   store.

## The document set

A key is `<root>:<kind>:<local>`. The leaf derives it, and admission refuses a
mismatch. The root is the campaign slug, or the instance for `instance`,
`stewardship` and `hand_off`.

| Kind | Local | Admitted by | Carries | Cites |
|---|---|---|---|---|
| `instance` | `self` | exists (`eureka:instance:self`) | instance, display name, host | |
| `stewardship` | `<repo>.n<seq>` | Self | instance, repo, sequence, note | |
| `campaign` | `self` | Self | title, repos, working branch, target doc | |
| `target` | `r<rev>` | Self | invariants (`label`, `statement`), not in scope, canonical implementations, doc | |
| `question` | `<label>` | Imagination; Hands or Soul for a fork | title, question, options (≥2), recommended, depends, raised in | `raised_in` |
| `ruling` | `<label>` | Self | answers (none for an operator direction), choice, ruling, operator quote, date, authority | `answers` |
| `cut_spec` | `cut-<cut>.r<rev>` | Imagination | repo, branch, base, depends on (cut labels, never revision ids; a spec may not depend on its own cut), first, deletes, keeps and moves, adds, file changes, authority map, verification, estimate | `rulings`, `questions` |
| `cut_report` | `cut-<cut>.h<attempt>` (a fix batch is the next attempt) | Hands | commits, range, verification evidence (mutation totals included), mutations (survivors and the ones Soul should rerun), deviations, forks, structural delta, landed names, undone, promises | `cut_spec`, `forks` |
| `verdict` | `cut-<cut>.s<pass>` | Soul | range, claims (each with an outcome, evidence, findings, promise, mutations) | `cut_report`, `findings` |
| `finding` | `cut-<cut>.s<pass>.<label>` | Soul, in the verdict's batch | confidence, severity, claim, invariants, locations, failure scenario, evidence, origin | `verdict` |
| `follow_up` | `<label>` | Self; Imagination for work no cut owns | source, repo, locations, item, why it can wait, owner | `source` |
| `resolution` | `<subject kind>.<subject local>.n<seq>` | whoever closes the subject | subject, sequence, outcome, rationale, date | `subject`, and the outcome's referents |
| `hand_off` | `<to>.<repo>.<date>` | Self (parked: Cut 12) | from, to, repo, documents, reason | `documents` |

Bounds: `Title` and `Short` are at most 200 bytes, `Line` 1,000, and `Para`
4,000. Narrative longer than that goes in the prose map, cited by a `DocRef`
(path, start and end line, commit). A `Label` is `[A-Za-z0-9_-]{1,64}`, and a
`Date` is `YYYY-MM-DD`. A subject's local key (the part after
`<campaign>:<kind>:`) is at most 64 bytes. A resolution's local is derived from
its subject's and is at most 111 bytes, so every admitted subject can be
resolved and withdrawn.

Rules that shape a batch (the rest arrive as refusals):

- A cut spec's repo must be one of its campaign's repos.
- A ruling that `answers` a question derives that question's `Answered`
  resolution in the same commit. Its `choice` must be one of the question's
  option labels. `operator_quote` is allowed only with `authority: Operator`.
- An operator direction that answers no question is a ruling with no
  `answers` and no `choice`, `authority: Operator`, and the operator's own
  words in `operator_quote`. Specs and briefs cite it by id, so every agent
  reads the operator's words rather than a paraphrase.
- A revision above 1 (of a target or a cut spec) needs, in its own batch, a
  resolution that supersedes the previous revision by it.
- A cut spec cites only rulings in force, and a report only a spec in force.
  The report's `range.head` is one of its commits; it may be spelled short or
  full, and is matched by commit.
- `depends_on` entries are cut labels naming another cut that has a `cut_spec`
  in the same campaign. A dependency on another campaign's cut goes in `first`.
- A verdict measures each of its report's promises exactly once. A `Falsified`
  claim needs a `Confirmed` finding, and an `Unproven` claim may not have one.
  A finding needs evidence and a location, and its invariant labels come from
  the target in force.

### Resolutions

One resolution in force per subject. `sequence` is the previous one plus one.
Nothing is edited or deleted: a closure is a new document, and so is its
reversal.

| Subject | Allowed outcomes |
|---|---|
| target | `Superseded { by: [target] }` |
| question | `Answered { by: ruling }` (derived), `Withdrawn { reason }` |
| ruling | `Superseded { by: [ruling] }` |
| cut_spec | `Superseded { by: [cut_spec of the same cut] }`, `Withdrawn { reason }` |
| finding | `Fixed { commit, by?: cut_report }`, `Deferred { to: follow_up or cut_spec }` (the spec must be in force), `Recorded { reason }`, `Withdrawn { reason }` |
| follow_up | `Fixed { commit, by?: cut_report }`, `Superseded { by: [follow_up] }`, `Withdrawn { reason }` |
| stewardship | `Superseded { by: [stewardship] }`, `Withdrawn { reason }` |
| resolution | `Withdrawn { reason }`, which reopens its subject. It cannot itself be withdrawn: resolve the subject again. |

Campaigns, cut reports, verdicts and instances have no resolution.

Only Self closes a finding `Fixed`, and only after a Soul pass on the fix's
report holds the claim the finding broke. Hands never resolves a finding: a fix
that closes itself is the self-grading the pipeline exists to prevent.

## Selection vocabulary

`query.selection` is CultNet's typed selection:

- `schemas` is a list of type ids, `epiphany.pipeline.<kind>.v2`.
- `keys` is a list of full ids.
- `fields` is a list of `{ index, op: "any_of", values: [..] }`. No alias is
  numeric.
- `cites` is `{ target: { schemaId, recordKey }, role? }`: the rows that cite
  that document.
- `cited` is `{ role, exists }`: the rows that some document cites (or none
  cites) through `role`.
- `projection` is `header` (default) or `document`.
- `descending` is a boolean.
- `limit` runs from 1 to 200, and 200 when absent.
- `cursor` takes the page's `next` for the page after. Every page of one walk
  is exact as of the first page's `as_of`.

The aliases:

| Alias | On | Values |
|---|---|---|
| `root` | every kind | the campaign slug, or the instance |
| `in_force` | every kind | `true`, `false` |
| `faculty` | every kind | the admitting faculty |
| `repo` | campaign, cut_spec, cut_report, follow_up, stewardship, hand_off, resolution | `Org/Repo`, case-insensitive |
| `cut` | cut_spec, cut_report, verdict, finding, resolution | the cut label |
| `severity`, `confidence`, `origin` | finding | `Blocker`/`High`/`Medium`/`Low`; `Confirmed`/`Plausible`; `Introduced`/`PreExisting` |
| `authority` | ruling | `Operator`, `Standing`, `Defaulted` |
| `claim_outcome` | verdict | `Holds`, `Falsified`, `Unproven` |
| `outcome` | resolution | `Superseded`, `Answered`, `Fixed`, `Deferred`, `Recorded`, `Withdrawn` |

A resolution's `repo` and `cut` are its subject's. Roles are named after the
field that carries them: `raised_in`, `answers`, `rulings`, `questions`,
`cut_spec`, `forks`, `cut_report`, `findings`, `verdict`, `source`, `subject`,
`superseded_by`, `resolved_by`, `deferred_to` and `documents`.

A value outside an alias's domain is refused as `SelectionInvalid`, never
answered empty. A header carries the id, the admission facts, the status and
the kind's triage fields, but no `Para` text: ask for `projection: document`,
or `view` one id, to read the prose fields.

`semantic: { text, top_k }` ranks the selection's matches by nearness to
`text`. The index supplies candidates and the selection decides membership, so
`in_force` means what it means anywhere else. A semantic query carries no
`cursor` and no `descending`. It is refused `Unavailable` while the index is
`Failing`.

## Recipes

These are the campaign's progress view. `<c>` is the campaign slug. Each recipe is
the `query` tool's whole input. Agents run them from the Rehydrate block in
`briefs.md`, which is the one definition of rehydration.

**Campaigns:**

```json
{ "selection": { "schemas": ["epiphany.pipeline.campaign.v2"] } }
```

- **No campaign at all:** the mind is new. Self opens one (SKILL.md step 0).
  Any other faculty stops and reports it.
- **`<c>` is not in the list:** the slug is wrong or the campaign is in another
  mind. Stop and report; never create a campaign to fit a brief.

**Target in force:** `target`, with `root` = `<c>`, `in_force` = `true` and
`projection: document`.

**Rulings in force**, operator directions included:

```json
{ "selection": { "schemas": ["epiphany.pipeline.ruling.v2"],
  "fields": [{ "index": "root", "op": "any_of", "values": ["<c>"] },
             { "index": "in_force", "op": "any_of", "values": ["true"] }] } }
```

**Open questions and follow-ups:**

```json
{ "selection": { "schemas": ["epiphany.pipeline.question.v2", "epiphany.pipeline.follow_up.v2"],
  "fields": [{ "index": "root", "op": "any_of", "values": ["<c>"] },
             { "index": "in_force", "op": "any_of", "values": ["true"] }] } }
```

A question's header carries `raised_in`. A spec named there is **blocked on the
operator**, not waiting on Hands.

**Open findings**, admitted by Soul:

```json
{ "selection": { "schemas": ["epiphany.pipeline.finding.v2"],
  "fields": [{ "index": "root", "op": "any_of", "values": ["<c>"] },
             { "index": "in_force", "op": "any_of", "values": ["true"] },
             { "index": "faculty", "op": "any_of", "values": ["Soul"] }] } }
```

Add `severity` any of `Blocker` and `High` for the blocking ones. `faculty` is
declared attribution, not checked by admission (see the gaps below), so a
finding or verdict from any other faculty is a defect to raise, not a record to
use.

**Specs with no report.** This is one query: `cited` with `exists: false` is
the substrate's absent inbound hop.

```json
{ "selection": { "schemas": ["epiphany.pipeline.cut_spec.v2"],
  "fields": [{ "index": "root", "op": "any_of", "values": ["<c>"] },
             { "index": "in_force", "op": "any_of", "values": ["true"] }],
  "cited": { "role": "cut_spec", "exists": false } } }
```

Before briefing Hands on one of them, check whether it is blocked: `question`,
`in_force` = `true`, with `"cites": { "target": { "schemaId":
"epiphany.pipeline.cut_spec.v2", "recordKey": "<spec id>" }, "role":
"raised_in" }`. A match means the spec waits on a ruling.

**Reports with no verdict** (Soul's queue): the same shape, over
`epiphany.pipeline.cut_report.v2`, with `"cited": { "role": "cut_report",
"exists": false }` and no `in_force`, because reports are never resolved. The
hop cannot filter the citing verdict's faculty.

**A subject's history**, newest first:

```json
{ "selection": { "schemas": ["epiphany.pipeline.resolution.v2"],
  "cites": { "target": { "schemaId": "epiphany.pipeline.<kind>.v2", "recordKey": "<id>" }, "role": "subject" },
  "descending": true } }
```

A withdrawn resolution is listed with the withdrawal as its status.

**One cut's record:** `schemas` set to `cut_spec`, `cut_report`, `verdict`,
`finding` and `resolution`, with `root` = `<c>` and `cut` = `<label>`. When
reading its verdicts and findings, check that `admission.provenance.faculty` is
`Soul`.

**The ledger:** `cut_spec` and `cut_report` with `root` = `<c>` and
`projection: document`. Compare each spec's `estimate` with its reports'
`structural_delta`. A miss gets its explanation in the next report's
`deviations`, or in the prose map if it spans cuts.

**Precedent** (before raising a question or recommending a mechanism):
`ruling`, `resolution` and `finding` with `root` = `<c>`, plus
`"semantic": { "text": "<the question in plain words>", "top_k": 10 }`.

## Substrate gaps

The known gaps in the mind's substrate are `follow_up`s in the mind, not a
list on this page. Each one names the gap, its owner, and in
`why_it_can_wait` the workaround the skill uses meanwhile. The workarounds
that steer agents are also written into the step or brief that applies them.
Examples are the mutation triage in `deviations`, the ruling id at the start
of a claim, and the retry on `Unavailable`.

Substrate gaps live under the standing campaign `eureka-substrate`
(operator ruling `eureka-substrate:ruling:gap-home`), with labels starting
`gap-`. That campaign is also where the substrate is fixed. Every campaign
reads its gaps with this query:

```json
{ "selection": { "schemas": ["epiphany.pipeline.follow_up.v2"],
  "fields": [{ "index": "root", "op": "any_of", "values": ["eureka-substrate"] },
             { "index": "in_force", "op": "any_of", "values": ["true"] }] } }
```

- **When a run works around a gap that is not there,** Self admits a new
  `gap-<name>` follow-up under that root. Its source is the document where the
  run felt the gap, and its owner is the missing thing's owner.
- **When a run hits a gap that is already there,** it admits nothing new. The
  run records the recurrence where it happened: a report's `deviations`, or the
  prose map. The count lives in that evidence until the follow-up kind can
  carry it.
- **Do not copy the list back here.** A table on this page is a second copy, and
  it goes stale the day an owner fixes a gap.

## The prose map

`docs/<campaign>-map.md` holds:

- **Body facts:** each probe, with what was run, where, when, and what it
  returned. Cut specs cite them by `DocRef` instead of restating them.
- **The model page:** one row per persistent kind, giving what names it, what
  happens to it over time, and who decides (SKILL.md step 0b).
- **Rationale:** why the cut order is what it is, why a design was rejected,
  and anything longer than a `Para`.

It has no progress section, no per-cut sections, no rulings and no ledger table:
those are documents, and the recipes above read them. `docs/<campaign>-target.md`
keeps the target's rationale and the design truths the migration produces. Its
invariants, not-in-scope list and canonical implementations are the typed
`target`.

## Notes from use

- **Test negative greps before publishing them** in a spec's
  `verification.negative`. `\.loadout\b` matched the legitimate schema name
  `aetheria.loadout`.
- **State the capture method with the capture.** PowerShell `>` writes a BOM and
  CRLF, and the comparison must use the same method on both sides.
- **Prefer normalizers that parse the format.** Ones that split on text leave
  false diffs, as the census normalizer did when it split on `, ` and glued the
  first maker to its kind column.
