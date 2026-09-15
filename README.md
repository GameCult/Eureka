# Eureka

Eureka is a Claude Code skill. It runs foundation changes (migrations, rebuilds,
teardowns, cross-repo and cross-runtime work) as a faculty pipeline:

- **Self** routes the work.
- **Imagination** maps the cut.
- **Hands** executes one cut at a time.
- **Soul** tries to falsify what Hands promised.
- **Mind Steward** keeps memory honest.
- **The operator** rules on real forks.

It is the Claude Code counterpart of [Epiphany](https://github.com/GameCult/Epiphany)
and shares Epiphany's faculty vocabulary.

The pipeline was extracted from the Aetheria CultCache migration
(2026-09-12..15). In that migration, 29 of 32 independent Soul passes found real
defects that the implementing agent's own tests had passed.
`references/postmortem-cultcache.md` has the evidence, and
`references/changelog.md` records every change to the skill along with the
evidence behind it.

## Install

Clone into your Claude Code skills directory:

```bash
git clone https://github.com/GameCult/Eureka.git ~/.claude/skills/eureka
```

Claude Code discovers the skill by the `name` and `description` in `SKILL.md`.

## Layout

- `SKILL.md`: the pipeline (the faculties, the loop, Self's discipline, and
  git/tooling rules).
- `references/briefs.md`: brief templates for Imagination, Hands, Soul, Mind
  Steward and Eyes.
- `references/cut-map.md`: the shape of the target document and the cut map.
- `references/postmortem-template.md`
- `references/postmortem-cultcache.md`: the worked example.
- `references/epiphany-comparison-2026-09-15.md`: a dated, source-grounded
  comparison with Epiphany.
- `references/changelog.md`

## Status

Eureka currently keeps pipeline state in committed documents and memory. A
campaign in Epiphany (`notes/eureka-pipeline-state-target.md`) is adding typed
pipeline state. Epiphany owns the schemas and admission. Each campaign's store
is committed in the repo where the task runs. A per-session `eureka-state` MCP
server lets Eureka agents admit and query that state. This skill will be rewired
to use it once that campaign lands.
