# Epiphany pipeline model (source-grounded) vs. the Eureka skill

Written 2026-09-15 by a read-only Modeling/Eyes pass. Epiphany HEAD is `71324718`
(2026-09-14), branch as checked out, worktree clean. The voidbot MCP was not
used; everything below comes from a direct Grep/Read of `F:\Projects\Epiphany`.
`.epiphany-run/` was ignored as stale.

Faculty names are as of this date. The skill's Mind Steward was renamed Life on
2026-09-25 (see the changelog); rows below that describe the skill's steward
mean that faculty. Epiphany's own `mind_steward` doctrine and its Continuity
(Reorientation) worker are described as they stood.

**Resolved (Mind Steward, 2026-09-15).** While this pass ran, the skill was
renamed from `epiphany-pipeline` to `eureka`, and its frontmatter and changelog
were then updated, so the drift this pass saw no longer exists.

**Not covered by this pass: MCP.** Epiphany has an rmcp *client* only
(`epiphany-tool-mcp-runtime/Cargo.toml:18`, `client` feature). It has no MCP
server.

---

## 0. What Epiphany actually is (one paragraph)

Epiphany is a Rust workspace. It is a library (`epiphany-core`, 55,650 lines of
tracked `.rs`) plus a release bundle that owns 9 `[[bin]]` targets
(Cargo.toml). It schedules **LLM worker passes** (Modeling, Research/Eyes,
Imagination, Mind plan-review, Verification/Soul, Reorientation, Persona)
through a **pure priority projection over typed CultCache state**. Each pass
returns a closed typed decision, and a per-family admission owner commits it
to the Mind store with batch compare-and-swap. The "pipeline" is state-driven,
not conversational: nobody writes a brief. The coordinator derives the next
action from which typed obligation exists.

---

## 1. Faculties and organs

| Faculty | Embodiment in source | Status |
|---|---|---|
| **Self** | `resident_self.rs` (3,105 lines): typed pressure, grant, lease, cooldown (`cooldown_seconds` :284), retry, settlement. `surfaces/coordinator_decision.rs:7-103` `recommend_coordinator_action`, a pure priority function. Binaries `epiphany-mvp-coordinator`, `epiphany-swarm`. | Implemented as deterministic code, not an agent. map.yaml calls it "partial". |
| **Modeling** | Worker role `modeling`; instructions at `current_work.rs:2885` (Body), `:3063` (proposal), `:3189` (frontier-verdict). Output schemas in `epiphany-openai-runtime/src/lib.rs:937-968`. Writes keyed RepoModel docs (`repo_model_documents.rs`). | Implemented. |
| **Eyes** | Worker role `research`, `current_work.rs:1610`. Immutable GitHub source identity. Evidence enters Mind as keyed evidence/observation documents. | Implemented. Launched only for an explicit external-evidence obligation (algorithmic map :856). |
| **Imagination** | Worker role `imagination`, `current_work.rs:1170` (frontier planning candidate), `:2738` (Persona-feedback consideration); `imagination_consideration.rs`. It proposes, and the next organ can only be Eyes or Imagination (`6e600e8d`, algorithmic map :876-883). | Implemented. |
| **Mind** (admission) | `reasoning_context.rs` commit owner: atomic batch CAS plus `EpiphanyMindCommitReceipt`. A **Mind plan-review worker** (`current_work.rs:1327`) adopts, refuses, or holds an Imagination candidate. anatomy.md:49-52 says this is a stateless admission procedure, not a sub-agent. | Implemented. |
| **Soul** | Worker role `verification`, `current_work.rs:1466` ("Audit only the exact typed Hands consequence..."). `soul_gateway.rs:3-58`: `SoulVerdictReceipt` (verdict is a `String`) and `RepoFrontierVerificationRequest`, which binds the Hands intent, patch, command and commit receipt IDs. | Implemented as a model pass over sealed receipts. |
| **Hands** | `hands_gateway.rs`: `HandsActionIntent`, and Patch/Command/Commit receipts. Writers are `runtime_spine.rs:7386,7422,7456`. **Every caller is in `current_work.rs` tests** (lines 4383-4471, inside `#[cfg(test)]` from :3309). `ContinueImplementation` is emitted by `coordinator_decision.rs:92-96`, but **Resident Self excludes it from the launchable set** (`resident_self.rs:974-993`, which returns `None`). No code path in core, OpenAI runtime or tool-mcp runtime produces Hands receipts. The writers are still re-exported as public crate API (`lib.rs:230-232`), even though their only callers are tests. | **Types and verification input only; no live actuator in the current tree (verified by grep).** map.yaml:275 still says "hands: proven for bounded consequences" and cites historical c011-era runs. |
| **Persona** | `persona_*.rs` (6 files) plus `epiphany-persona-service` (Projector, Persona, Interpreter stages) and `epiphany-persona-discord-permit`. | Implemented, "partial" per map.yaml. |
| **Continuity** | `reorientation_work.rs` worker (`:475`, "Decide resume or regather"). `EpiphanyCoordinatorDeathRecovery`, archived session tombstones. | Implemented as a worker plus runtime tombstones. |
| **Mind Steward** | **No code.** It exists only as agent doctrine: `AGENTS.md:81-103` requires a Codex/Claude `mind_steward` sub-agent over `state/map.yaml`, the handoff, and the algorithmic map. | Docs/agent-procedure only. |
| **Nervous system** | Heartbeat store `state/agent-heartbeats.msgpack`, Resident Self grants/cooldown, runtime-spine jobs. AGENTS.md:197-201 heartbeat physiology rules. | "partial" (map.yaml organ_readiness). |
| **Substrate Gate** | `substrate_gate.rs`: grants/refusals, and `HandsActionIntent.substrate_gate_grant_receipt_id`. | Implemented (types). |
| **Operator** | Not an organ. See §5. | — |

The docs-only faculty surfaces are the Mind Steward and the dependency matrix.
`notes/organ-dependency-contracts.md` still says "every embodied sub-agent
depends on all the others", but the code matrix was deleted in `2aeab7a9`.

## 2. Routing and scheduling

- **The priority projection is pure** (`coordinator_decision.rs:7-103`; algorithmic map :1128-1143), in this order:
  1. Mind missing, then Reorientation, then operator regather;
  2. frontier Planning stages (Imagination, then Mind review, then commit);
  3. proposal, Body, and frontier-verdict Modeling;
  4. Verification;
  5. Research;
  6. Imagination considerations;
  7. Hands-ready;
  8. otherwise await a proposal.

  "No default Modeling job, latest lane, accepted-at comparison, runtime event,
  or generic interrupt can manufacture work" (:1142).
- **Input:** `current_work.rs` projects one pulled CultCache snapshot into
  family obligations. Each family carries an `EpiphanyAgentPassAttemptProjection`
  (Launch/Wait/Review) (:1183-1197). A failed attempt changes the projection
  digest, so Resident Self grants exactly one fresh pressure. Replaying an
  unchanged failure is idempotent.
- **Launch:** Resident Self converts the action into a grant
  (`resident_self_current_work_action`, :965-1001). The coordinator launches a
  worker process. The sealed typed worker launch document owns family identity
  (`edb5c3a3`).
- **Briefing:** the instruction is a **one-sentence hardcoded string per family**
  (`current_work.rs:1170,1327,1466,1610,2738,2885,3063,3189`;
  `reorientation_work.rs:475`). The OpenAI runtime appends the sealed typed
  projection (`dynamic_prompt_context`), a family output contract text, and
  tool/evidence mandates (`epiphany-openai-runtime/src/lib.rs:326-339, 922-935`).
  There are no free-form briefs. Context is the sealed `EpiphanyReasoningBasis`
  (algorithmic map :1029-1035). The legacy prompt-TOML specialist prompts exist
  only in `.epiphany-run` (stale).
- **Tracked residue:** `epiphany-state-model/src/prompts/*.md` (2 files) is still
  tracked although the package was deleted in `07529fb5`.

## 3. Verification

- **Chain:** Hands receipts, then a `RepoFrontierVerificationRequest` (binds the
  exact receipt IDs, frontier item hash, and model projection digest), then a
  Verification worker pass, then `SoulVerdictReceipt`, then a derived frontier
  Modeling request (`runtime_spine.rs:7154-7215`).
- **Gate vocabulary:** `"pass"` resolves to `Resolved`;
  `"needs-review"|"needs-evidence"|"fail"` map to `Blocked`; anything else is an
  error (`runtime_spine.rs:7197-7200`). This is a string match, not an enum. The
  verdict must byte-match the worker result's verdict, summary, risks and
  evidence (:7207-7214).
- **Anti-self-report:**
  - The Verification projection is sealed. Since `24023265` it is the sole Hands
    receipt input, so Soul cannot reread mutable runtime state (map.yaml:46-65).
  - Provider success cannot launder malformed output: native decoding and family
    admission are final (`553f79d9`).
  - A structurally valid but semantically refused result writes a typed
    admission-refusal and schedules a retry (algorithmic map :1390-1394).
  - `a01c6842` deleted the coordinator's "same-function always-approved Hands
    review".
- **What is absent:**
  - No mutation testing anywhere (grep for mutants found nothing).
  - No requirement that Verification runs a different model or worker identity
    than Hands (grep found no distinctness check). Independence comes from
    separate job/launch/basis, not from an adversarial brief.
  - No CONFIRMED/PLAUSIBLE grading.
  - The Soul brief is one sentence, "Audit only the exact typed Hands
    consequence", so it is an audit, not a falsification mandate.
  - No INTEGRATE / INTEGRATE_WITH_FOLLOWUPS verdicts.
- **Repo-development verification** (humans/Codex building Epiphany itself):
  - Focused `cargo` tests per cut, recorded as counts in map.yaml (for example
    "Core 152/152").
  - Idunn CI gate on Yggdrasil with SHA-256 test receipts (algorithmic map
    :1414-1418).
  - Live "capstones" (Ox10..Ox17, Capstone 17) as end-to-end falsification. Each
    failure is sealed as evidence and never resumed (:1440-1502).
- **Lessons doc:** `notes/faculty-workflow-lessons-2026-09-04.md` records that a
  Soul **writing tests** produced the best findings (:49-55), and proposes a
  typed `Verdict {HOLDS|FALSIFIED|UNPROVEN}` (:151-152). That is **not
  implemented**.

## 4. Plans and maps

- Durable **executive map:** `state/map.yaml`, 292 lines, AGENTS.md:60-80. It
  holds objective, invariants, `current_status` (one cut entry per landed SHA
  with net lines and verification), `active_subgoals`, `organ_readiness`,
  `forbidden_actions`, and `memory_policy`. It plays the role of the skill's
  **status header**, but it is YAML, not CultCache.
- **Mechanism map:** `notes/epiphany-current-algorithmic-map.md` (1,526 lines)
  carries owner/inputs/outputs/invariant tables (:841-862) and per-SHA cut
  narratives. **Campaign plan:** `notes/epiphany-fork-implementation-plan.md`
  (945). **Handoff:** `notes/fresh-workspace-handoff.md` (2,343 lines).
- **Evidence ledger:** `state/ledgers.msgpack` via `state_ledger.rs`. It is a
  single-key CultCache entry holding `Vec<branches>` and
  `Vec<evidence{ts,type,status,note}>`, and each append rewrites the entry
  (:52-64). The CLI is `epiphany-state add-evidence`.
- **In-runtime plans:** Imagination frontier candidates, then a Mind plan
  decision (adopt/refuse/hold) as keyed `RepoFrontierRoute`, plus `repository_scope`
  and `authorized_paths` ceilings (`5b799b12`). These are typed and CAS'd.
- **No per-migration target doc or cut map** in the skill's sense. Cuts are
  recorded after the fact in map.yaml and the algorithmic map, not specified
  ahead of time to file:line.
- **Operator rulings:** there is no typed ruling artifact. In the runtime, the
  operator objective enters via `coordinator_objective_intake.rs:45-78`
  (`UserObjectiveIntake`, which refuses to replace an existing objective). In
  repo development, rulings live as prose invariants in map.yaml and AGENTS.md.
  The lessons doc (:153-158) proposes "Rulings as a first-class artifact". That
  is **not implemented**.

## 5. Operator interaction

- `RegatherManually` is the only operator-question action. It fires when an
  accepted continuity decision sets `operator_regather_required`
  (`coordinator_decision.rs:27-32`, `current_work.rs:533-539`).
- `PrepareCheckpoint` fires when Mind is missing and requires an operator
  objective (:10-15).
- The consent/approval surface is the canonical **swarm brake** plus
  **deployment brake**, and Idunn operator grants that open and expire
  (map.yaml:40-41). `forbidden_actions` (map.yaml) forbids speculative
  deployment grants.
- "Humans talk to Face" (AGENTS.md:189-192). The Aquarium UI moved to a sibling
  repo (`apps/README.md`) and is not in this body. The former Discord operator
  bridge is deleted (algorithmic map :1507).
- There is no bundled fork/question document with a recommendation, and no
  ruling write-back path besides objective intake and brake/grant transactions.

## 6. Memory

- **Runtime Mind:** keyed CultCache documents in the runtime `.cc` store, with
  singleton objective/focus/mode/RepoModel binding and keyed evidence,
  invariants, checkpoints, Persona memories and more (algorithmic map :981-1001).
  Merge law :1105-1114. There is no aggregate head and no semantic cache
  (`856648de` deleted Qdrant/Ollama/Postgres projection).
- **Persona memory:** `admit_persona_state_notes` writes keyed Mind documents
  (`persona_conversation.rs:1018`). The repo publishes
  `schemas/cultnet/gamecult.persona_state.v0.schema.json` but does not consume it
  (consistent with `F:\Projects\CLAUDE.md`).
- **Repo-development memory:** map.yaml, handoff, and ledger, maintained by the
  agent-side `mind_steward` procedure (AGENTS.md:81-103, 144-151, 216-221). No
  steward organ exists in code, and nothing triggers the steward structurally.
  The lessons doc :165-168 proposes boundary triggers; they are **not
  implemented**.
- `epiphany-agent-memory-store` was removed in `387afe49` (verified: that commit
  deletes it along with about 28 other bins).

## 7. Observability

- **Eve surface:** only Model Atlas has one (`atlas/eve_surface.rs`, 1,597
  lines). Coordinator status uses string `operator_status()` values
  (`resident_self.rs:582-593`) and the `epiphany-state status` CLI.
  perfect-machine-audit-roadmap.md:53 lists "Eve/CultUI operator interface" as
  **open**.
- **Audit:** `epiphany-model-runtime audit-decision` / `list-decisions`
  reconstruct any terminal pass from typed records without transcripts
  (algorithmic map :1403-1409). CultMesh projects reasoning basis, decision
  context, and commit receipt read-only (map.yaml:118).
- **Budgets:**
  - Time: one outer worker budget; Persona `--turn-timeout-seconds`, default
    600s (algorithmic map :1041-1047).
  - Tokens: recorded on receipts only (`input_tokens`, `output_tokens`,
    `reasoning_output_tokens`, `cached_input_tokens`, from
    `epiphany-model-adapter/src/native.rs:153-167`). No token-budget enforcement
    was found.
  - `reasoning_effort` is an optional per-request field.
  - No model-selection-by-criticality policy.
- **Build/verify footprint:** each cut in map.yaml records verification output
  size (for example "Verification generated 6.349 GiB across 7,376 files";
  map.yaml:79-80).

## 8. Failure handling

- **Typed failure terminality:** `EpiphanyModelPassFailure`, bound to the sealed
  context. One shared failure owner covers role, reorient, and Persona
  (`bb823c54`, algorithmic map :1082-1097).
- **Retry:** a changed attempt digest yields one fresh grant, and proposal
  attempt ordinals are contiguous (:1191-1197). Admission refusal writes a typed
  refusal and a retry with prior refusals in context (:1390-1396).
- **Crash:** `EpiphanyCoordinatorDeathRecovery` competes with success/failure
  receipts through one `EpiphanyCoordinatorRunTerminality` identity (:1220-1231).
  Archived session tombstones prevent identity resurrection (:941-951).
- **Compaction (agent-side):** AGENTS.md:153-180 re-entry rite.
- **Schema epochs:** hard cuts refuse old writable stores, with no migrator or
  dual reader (for example Runtime v45 / Mind v11, map.yaml:76).
- **Wrong organ output:** refusal documents; no Mind write; the run is sealed and
  never resumed (Ox10/12/13/15/16 narratives, algorithmic map :1440-1502).
- **Scars recorded in-repo:**
  - capstone narratives;
  - `faculty-workflow-lessons` (integration is a gated sequence, :116-125; push
    gated on the result line, not the launch, :127-135);
  - AGENTS.md build-economy rules (:250-277).

## 9. Scale and structure

- **Workspace members** (Cargo.toml): 5 crates plus the root release bundle, with
  9 `[[bin]]`: release, state, repository-body, swarm, persona-service,
  persona-discord-permit, mvp-coordinator, model-runtime, tool-mcp-runtime. That
  is down from about 75 core bins; `387afe49` alone removed about 28.
- **Tracked source:** 77 `.rs` files, **65,113 lines**. The giants are
  `runtime_spine.rs` 8,899; `current_work.rs` 5,714; `openai-runtime/lib.rs`
  3,350; `resident_self.rs` 3,105; `reasoning_context.rs` 2,715.
- **Liability observations:**
  - The repo-local `target/` is **39 GiB** across 113,504 files. AGENTS.md:117-123
    says builds should use the shared `C:\Users\Meta\.cargo-target-codex` target,
    so this root is exactly the kind of unowned output root the build-economy
    rules forbid (AGENTS.md:273-277).
  - The git-ignored `.epiphany-run/` sandbox is **105 GiB**. It is stale, not a tool
    (per `F:\Projects\CLAUDE.md`), but it is the single largest disk liability in the
    repository. Together with `target/`, about 144 GiB of output sits beside 65k
    lines of source.
  - The deployed package still lists "26 binaries plus witness" (algorithmic map
    :1418, historical `d2ca6630`).
  - Untracked empty crate directories remain: `epiphany-openai-auth-spine`,
    `epiphany-openai-codex-spine`, `epiphany-release-construction`,
    `epiphany-self-policy` (0 files each).
  - Tracked orphan prompts remain in `epiphany-state-model/src/prompts/`.
  - The `.gitignore` still names deleted crates (`epiphany-openai-adapter`,
    `epiphany-codex-bridge`, `apps/epiphany-gui`).
  - Note bulk: notes/ totals about 10.6k lines. The handoff alone is 2,343 lines
    and repeats cut narratives also in map.yaml and the algorithmic map. That
    is triple-recorded cut history.
  - The Model Atlas code (about 10k lines under `atlas/`) is "code-complete",
    but Gate 1 is paused and it is operationally unaccepted.
  - The ledger uses `.msgpack` single-file stores, not `.cc`.

## 10. Known gaps and stale docs

- **Hands claimed "proven"** (map.yaml:275) while current source has no live
  receipt producer and Resident Self won't launch `ContinueImplementation`
  (§1). Verified by grep.
- **No accepted end-to-end run on the current package.** The objective
  (map.yaml:7) is still diagnosing the Aug 25 Luna connector failure. Capstone
  17 and Atlas Gate 1 are open, and production is inactive and braked.
- `notes/epiphany-anatomy.md:61-62` still expects "typed continuity packets,
  recovery receipts, compaction checkpoints, stale-turn repairs". Those contracts
  were deleted in `ca2d2cf2` and `fed4b857` (map.yaml:183).
- `notes/organ-dependency-contracts.md` describes the dependency matrix deleted
  in `2aeab7a9`.
- `notes/perfect-machine-audit-roadmap.md` (dated 2026-08-12) cites the deleted
  "coordinator state transaction" and old test counts (684/684). It is still
  listed as "Active Design Reference" in `notes/README.md:28`.
- The `README.md` "What She Is" list names "heartbeat, sleep, memory"
  machinery, and the Continuity/Substrate Gate receipt families are partly
  deleted (inferred mismatch; not line-audited).
- `docs/epiphany_body_whitepaper` is explicitly marked historical (README:220).
- `faculty-workflow-lessons` proposes 7 typed artifacts: faculty artifact
  schemas, rulings, landed-names digest, owner-scoped edit queues, steward
  triggers, Self budget, swarm visibility. **None exist in code** (grep for
  verdict/ruling/digest types found only `SoulVerdictReceipt` with a string
  verdict).
- The skill frontmatter name mismatches its directory (see header).

---

## Comparison table: Eureka skill vs. Epiphany

| Dimension | Skill (Eureka) | Epiphany | Evidence |
|---|---|---|---|
| **Self / router** | Root LLM agent routes by judgment, keeps and commits maps, talks to operator. | Deterministic pure priority function over typed obligations; Resident Self grants/leases/cooldowns. No LLM router. | Skill SKILL.md:24-27, 210-232. Epiphany `coordinator_decision.rs:7-103`, `resident_self.rs:965-1001`. |
| **Unit of work** | A "cut" from a hand-authored cut map (repo-scale refactor). | A typed family obligation (Body Modeling, frontier item, Verification request...) in a RepoModel graph. | cut-map.md:31-56. Algorithmic map :1128-1197. |
| **Planning artifact** | Target doc (ends) and cut map (means), specified ahead to file:line with authority maps and a subtraction ledger. | Imagination candidate, then Mind plan-review adopt/refuse/hold, then keyed `RepoFrontierRoute` with `repository_scope`/`authorized_paths`. Repo dev records cuts **after** landing in map.yaml. | SKILL.md:60-112. `current_work.rs:1170,1327`; `5b799b12`; map.yaml:45-188. |
| **Briefs** | Rich templates: invariants, promises to falsify, standing rulings, git rules. | One-sentence hardcoded instruction per family, plus sealed typed projection, output schema text, and tool mandates. | briefs.md:16-173. `current_work.rs:1466` etc.; `openai-runtime/lib.rs:326-339,922-935`. |
| **Hands** | Subagent commits and pushes small cuts, runs its own mutations, reports structural delta. | Typed Intent/Patch/Command/Commit receipts with path ceilings; **no live producer in current source**; `ContinueImplementation` not launchable. | SKILL.md:126-147. `hands_gateway.rs`; writers only in `current_work.rs` tests (:3309+); `resident_self.rs:974-993`. |
| **Soul independence** | Different agent; adversarial brief listing Hands' promises; reruns builds; designs non-revert mutations; probes at the failing layer. | Separate worker/job over a **sealed** receipt projection; audit-framed one-line brief; no mutation testing; no distinct-model/worker check. | SKILL.md:149-167. `current_work.rs:1466`; `24023265`; grep (no mutants, no distinctness). |
| **Verdict shape** | Findings CONFIRMED/PLAUSIBLE, with file:line, scenario and severity, plus promises that held. | `SoulVerdictReceipt.verdict: String`; "pass" becomes Resolved, "needs-review/needs-evidence/fail" become Blocked; byte-equality with the worker result. | SKILL.md:163-164. `soul_gateway.rs:13`; `runtime_spine.rs:7197-7214`. |
| **Self-report protection** | Structural: a different agent reruns everything. Rule "never claim a result before its notification". | Structural: sealed basis/context; native decode plus family admission final; provider success can't launder; typed refusal; always-approved review deleted. | SKILL.md:232. Algorithmic map :1049-1072, :1390-1396; `a01c6842`. |
| **Soul loop cap** | Explicitly uncapped on foundation cuts; track hit rate. | Retry is per failed attempt (one fresh grant per changed digest); no concept of repeated Soul passes over the same consequence. | SKILL.md:178-185. Algorithmic map :1191-1197. |
| **Operator rulings** | Bundled questions with options and a recommendation; dated rulings in the map; superseded text marked history. | No typed ruling artifact. Objective intake (refuses replacement); `RegatherManually`; brakes and expiring Idunn grants. | SKILL.md:114-124; cut-map.md:22-25. `coordinator_objective_intake.rs:45-78`; `coordinator_decision.rs:27-32`; map.yaml:40-41. Lessons doc :153-158 (proposed). |
| **Consent / approval gates** | Operator rules forks; git push per cut without further gating. | Swarm brake, deployment brake, Substrate Gate grants, Bifrost signed receipts for public consequence. | map.yaml:33-42; `substrate_gate.rs`; `HandsActionIntent.substrate_gate_grant_receipt_id`. |
| **Memory / steward** | Mind Steward subagent at phase boundaries; falsifies one claim; names mutations. | Runtime: keyed CultCache Mind with CAS merge law. Repo dev: same steward procedure as agent doctrine only; no steward organ or structural trigger. | briefs.md:142-158. Algorithmic map :981-1124; AGENTS.md:81-103. |
| **Durable state format** | Markdown docs committed in the changed repo. | Runtime `.cc` typed documents (CultCache); repo dev uses YAML map, markdown notes, and a msgpack ledger. | cut-map.md:3-10. `reasoning_context.rs`; `state/map.yaml`; `state_ledger.rs:14-64`. |
| **Audit / provenance** | Commit SHAs, Soul reports, postmortem from evidence. | Transcript-free `audit-decision` / `list-decisions` from sealed basis, context and commit receipt; SHA-256 CI test receipts. | postmortem-template.md. Algorithmic map :1403-1418. |
| **Observability** | Status header in the map; Self relays summaries. | map.yaml `current_status`; `epiphany-state status`; string operator statuses; Eve only for Atlas; operator Eve UI open. | cut-map.md:12-29. `resident_self.rs:582-593`; `atlas/eve_surface.rs`; audit-roadmap.md:53. |
| **Budgets** | Model choice by criticality; subtraction budget as pressure. | One outer time budget per pass; tokens recorded, not enforced; per-cut net-lines and verification-GiB recorded. | SKILL.md:220-227. Algorithmic map :1041-1047; `model-adapter/native.rs:153-167`; map.yaml:79-80. |
| **Failure / recovery** | Stop at a building commit boundary; triage into fix, fork or follow-up; git scars. | Typed `EpiphanyModelPassFailure`; death recovery; tombstones; epoch hard cuts; failed capstones sealed and never resumed. | briefs.md:92-93; SKILL.md:169-176, 234-254. Algorithmic map :1082-1097, :1220-1231, :1440-1502. |
| **Compaction / re-entry** | Maps committed; steward at boundaries. | AGENTS.md re-entry rite plus steward; runtime Reorientation worker decides resume or regather from a sealed continuity projection. | AGENTS.md:130-180; `reorientation_work.rs:475`. |
| **Build economy** | Detached builds with log and PID; tag-push limit; reproducible byte checks. | One package per entrypoint; focused single-package cargo only; Idunn owns broad builds; interrupted builds settled before retry. | SKILL.md:247-249. AGENTS.md:250-277. |
| **Scale evidence** | 1 migration: 114 subagents; 29/32 Soul passes found defects (about 75). | 2,269 commits; about 65k tracked Rust lines; 9 bins; no accepted current-package end-to-end capstone. | postmortem-cultcache.md:10-22. `git log`; Cargo.toml; map.yaml:7, 114-118. |
| **What each proposes but lacks** | Nothing typed: all artifacts are prose and habits. | Lessons doc proposes typed Verdict, Rulings, landed-names digest, edit queues, steward triggers, and a Self budget, matching the skill's habits; none are implemented. | faculty-workflow-lessons-2026-09-04.md:146-176. |
