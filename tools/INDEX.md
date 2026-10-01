# Shared tools

One line per script. Briefs name the exact script they want; agents do not
browse. A line whose consuming brief no longer names the script is dead and is
deleted. Contributions come by branch and pull request. A script that verdicts
depend on gets a Soul pass before merge.

| script | purpose | consumer | named by |
|---|---|---|---|
| `tools/stopgap/ygg-verify.sh` | Pushes an exact revision to a mirror on Yggdrasil and runs one command in a capped, niced container. Dies with the stopgap when Idunn's verify transaction lands. | Hands, Soul, Imagination probes | `references/briefs.md` (Hands and Soul verification), `SKILL.md` (Yggdrasil) |
