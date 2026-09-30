#!/usr/bin/env bash
# STOPGAP: run a verification job for an exact revision on Yggdrasil, not on
# the operator's workstation.
#
# Why: on 2026-09-22 Starfire froze under compiler, test and stress load that
# Eureka agents had put on it. The operator ruled that Idunn owns verification,
# through a verify transaction mapped as its own campaign. That transaction
# takes a frozen revision, runs declared steps in a capped runner, returns a
# typed verdict, seals nothing and needs no brake. This script covers the gap
# until it lands.
#
# DELETION LINE: this file dies in the Idunn verify campaign's cut that makes
# Eureka use `idunn verify`. When that lands, SKILL.md stops naming this
# script, and `~/eureka-verify` on Yggdrasil is removed.
#
# What it does:
#   1. Pushes <rev> from a local repo to a bare mirror at
#      ~/eureka-verify/repos/<name>.git on Yggdrasil. Unpushed commits work too.
#   2. Clones the mirror into a scratch work directory on Yggdrasil and checks
#      the commit out detached. It is a real clone, not a worktree, because a
#      worktree's .git file points at a host path the container cannot see.
#   3. Runs <command> in <image> under a CPU and memory cap, niced. Each
#      toolchain gets one shared registry cache. The build output directory
#      stays inside the work directory and is never shared between checkouts.
#      CARGO_TARGET_DIR is deliberately NOT set: cargo's default (<workspace>/
#      target) is already inside /src, and forcing it made cargo-mutants' --jobs
#      workers share one target dir and test each other's binaries, so parallel
#      kill counts were noise (Soul, idunn-watchdog, 2026-10-01).
#   4. Removes the work directory unless KEEP=1, and exits with the job's status.
#
# At most $SLOTS jobs run at once on Yggdrasil. The operator raised this to 3 on
# 2026-09-22 ("the other cores are mostly sitting idle") and asked on 2026-09-30
# for Yggdrasil to be "absolutely pinned", so it went to 5. Measured the same
# night: 40% CPU idle and 53 of 62 GiB available with ~20 jobs queued, running
# jobs using ~1 GiB each. So it is 8, each capped at 4 CPUs and 6 GiB (MEM
# overrides per job; a big link can ask for more). The CPU caps oversubscribe
# the 16 cores on purpose: jobs run at nice 10, so the live services still win
# the scheduler. Memory is the real ceiling: 8 x 6 GiB worst case leaves the
# services (~9 GiB resident) their share of the 62.
# DISK is the ceiling that bit: at 8 slots (2026-09-30 01:50 CEST) /proc/pressure/io
# read full avg60=41%, and live Odin's fsyncs stalled long enough for Idunn's route
# challenges to time out. Back to 5 slots; CPU and memory headroom do not mean
# IO headroom. Watch /proc/pressure/io before raising this again.
#
# A job whose container sits under $5% of one core for $IDLE seconds
# (default 900) is killed and comes back red: on 2026-09-30 three hung test
# binaries held every slot for up to an hour at ~2% CPU while agents queued.
#
# There is no hand-written mutation harness: the operator retired it on
# 2026-09-22. Mutation testing uses the ecosystem's tools on a cut's diff.
#
# TWO RAKES, both paid for on 2026-09-23:
#  * The command runs under `bash -o pipefail -c`, and BASH_ENV points every child
#    bash at a file holding `set -o pipefail`, so a job SCRIPT run as `bash job.sh`
#    inherits pipefail too. (Exporting SHELLOPTS did that but also leaked a job's
#    `set -u` into bash-wrapped tools: kotlinc died on `JAVA_OPTS: unbound variable`,
#    2026-09-30.)
#    (the -o flag alone does not reach child shells; Soul proved a failing piped
#    test in a job script came back exit 0, 2026-09-30). Pipefail forced since
#    2026-09-30, after an ack Cut 2 job piped a failing test run into `cut` and
#    came back exit 0). pipefail does not rescue `a; b`: the job's status is the
#    LAST statement's, so a command ending in `git checkout`, `echo` or a filter
#    that succeeds still reports zero. Keep the verdict-bearing command last, and
#    a grep that matches nothing now fails the job (that is a signal, not noise).
#    Under pipefail `cmd | grep -q X` reads FALSE even on a match: grep exits at the
#    first hit, cmd dies of SIGPIPE, and its status wins (a media FEC mutation run
#    reported killed mutants as survivors this way, 2026-09-30). Capture to a file
#    and grep the file, or use `grep -c`/`grep` without -q.
#  * CultLib has no Cargo.toml at its root. A rust job must `cd packages/<crate>`
#    first, or cargo fails in a way that looks like the image is wrong.
#
# EDITING: bash reads a running script from disk as it goes, so editing this
# file in place breaks every job still running it (one died with "unexpected
# EOF", 2026-09-22). Write the new version to a temp file and rename it over
# this one.
#
# Usage (Git Bash on Starfire):
#   ygg-verify.sh <local-repo> <rev> <image> '<command>'
#   TIMEOUT=<seconds> caps the job (default 3600); a killed job exits non-zero.
#   IDLE=<seconds> kills a job idle that long (default 900; 0 disables).
#   DOCKER_ARGS='<extra docker run flags>' passes through to the container's
#   own `docker run`, appended after the fixed flags and before the image name
#   (e.g. DOCKER_ARGS='--sysctl net.ipv6.conf.all.disable_ipv6=0' or
#   DOCKER_ARGS='--network host'). Word-split by the remote shell, so quote a
#   flag's own value inside the string if it needs one.
# Images:
#   rust    eureka-verify-rust:<Dockerfile hash>   (rust 1.95, cargo-mutants, sccache;
#           every job shares the eureka-sccache volume at /sccache, keyed by
#           input hash, so a cold /src/target still reuses compiled crates)
#   kotlin  eureka-verify-kotlin:<Dockerfile hash> (JDK 21, kotlinc 2.2.21, Node 24, pwsh;
#           for packages/cultmesh-kotlin: `pwsh -File build.ps1`)
#   dotnet  mcr.microsoft.com/dotnet/sdk:10.0   (install Stryker in the command:
#           dotnet tool install -g dotnet-stryker)
#   any other value is used as an image name as-is.
# Example:
#   ygg-verify.sh /f/Projects/Huginn HEAD rust \
#     'cargo test --workspace && git diff BASE HEAD > /tmp/d && cargo mutants --in-diff /tmp/d'
set -euo pipefail

repo=${1:?local repo}; rev=${2:?revision}; image=${3:?image}; cmd=${4:?command}
host=${YGG_HOST:-ygg}; cpus=${CPUS:-4}; mem=${MEM:-6g}; slots=${SLOTS:-5}
timeout_s=${TIMEOUT:-3600}; idle_s=${IDLE:-900}
docker_args=${DOCKER_ARGS:-}
here=$(cd "$(dirname "$0")" && pwd)
sshopts=(-o BatchMode=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=4)

sha=$(git -C "$repo" rev-parse --verify "$rev^{commit}")
name=$(basename "$(git -C "$repo" rev-parse --show-toplevel)")
case "$image" in
  rust|kotlin) image=eureka-verify-$image:$(sha256sum "$here/$image.Dockerfile" | cut -c1-12) ;;
  dotnet) image=mcr.microsoft.com/dotnet/sdk:10.0 ;;
esac

ssh "${sshopts[@]}" "$host" "mkdir -p ~/eureka-verify/repos ~/eureka-verify/work ~/eureka-verify/images && \
  { test -d ~/eureka-verify/repos/$name.git || git init -q --bare ~/eureka-verify/repos/$name.git; }"
# ssh:// rather than scp-style host:path: Git LFS's pre-push hook rejects the
# scp form as a remote name and stalls (Aetheria, 2026-09-30). The verify mirror
# never needs LFS objects pushed; a job that needs one smudges it itself.
GIT_LFS_SKIP_PUSH=1 git -C "$repo" push -q "ssh://$host/~/eureka-verify/repos/$name.git" "$sha:refs/verify/$sha" --force
case "$image" in
  eureka-verify-*:*) df=${image#eureka-verify-}; df=${df%%:*}
    scp -q "$here/$df.Dockerfile" "$host:eureka-verify/images/$df.Dockerfile" ;;
esac

# ssh joins its arguments into one string that the remote shell splits again,
# so every argument is quoted here. Without that, `a && b` in the command runs
# b on the host.
remote_args=$(printf '%q ' "$name" "$sha" "$image" "$cpus" "$mem" "$slots" "${KEEP:-0}" "$cmd" "$timeout_s" "$docker_args" "$idle_s")
# The heredoc below travels with whatever line endings this file has on disk.
# On Windows that is CRLF, and the remote bash then fails on `set -euo pipefail`
# BEFORE `set -e` is in force, so the script limps on and can exit 0 — a job that
# never ran, reported as success (seen 2026-09-23). `tr -d` strips the CRs on the
# far side before bash ever sees them. The sentinel below is the second guard: if
# the remote script dies early, no verdict line is printed and the local side
# refuses to report a status it did not receive.
(ssh "${sshopts[@]}" "$host" "tr -d '' | bash -s -- $remote_args" <<'REMOTE'
set -euo pipefail
name=$1 sha=$2 image=$3 cpus=$4 mem=$5 slots=$6 keep=$7 cmd=$8 timeout_s=$9 docker_args=${10} idle_s=${11}
root=~/eureka-verify
case "$image" in
  eureka-verify-*:*)
    df=${image#eureka-verify-}; df=${df%%:*}
    if ! sudo docker image inspect "$image" >/dev/null 2>&1; then
      sudo nice -n 10 docker build -q -t "$image" -f "$root/images/$df.Dockerfile" "$root/images" >/dev/null
    fi ;;
esac
# Take whichever slot frees first. On 2026-09-22 a job waited on one fixed slot
# while another freed, and stayed stranded for over an hour.
slot=""; waited=0
while [ -z "$slot" ]; do
  for i in $(seq 1 "$slots"); do
    exec {fd}>"$root/slot-$i.lock"
    if flock -n "$fd"; then slot=$i; break; fi
    exec {fd}>&-
  done
  if [ -z "$slot" ]; then
    [ "$waited" -eq 0 ] && echo "ygg-verify: all $slots slots busy; waiting" >&2
    waited=1; sleep 5
  fi
done
work=$(mktemp -d "$root/work/$name-${sha:0:10}-XXXX")
trap 'if [ "$keep" != 1 ]; then sudo rm -rf -- "$work"; fi' EXIT
git clone -q --no-checkout "$root/repos/$name.git" "$work"
git -C "$work" checkout -q --detach "$sha"
echo "ygg-verify: $name@${sha:0:10} slot $slot, image $image, cpus $cpus, mem $mem, work $work" >&2
# A job that hangs must come back red, not hold its slot and its caller forever
# (2026-09-23: a test process idled at 0% CPU for 25 minutes and the agent
# waiting on it never woke). The watchdog kills the named container; killing
# the docker client alone would leave the container running.
cname="eureka-verify-$slot-$$"
# The subshell must not inherit the slot lock: its sleep outlives a job that
# finishes early, and an inherited fd held slot 2 for an hour (2026-09-23).
# It also kills a job that has idled for $idle_s seconds: docker's CPU% is per
# core, and a hung test reads ~2%, a working one tens to hundreds.
( exec {fd}>&- 2>/dev/null
  start=$(date +%s); idle=0
  while sleep 60; do
    if [ $(( $(date +%s) - start )) -ge "$timeout_s" ]; then
      sudo docker kill "$cname" >/dev/null 2>&1 && echo "ygg-verify: TIMEOUT after ${timeout_s}s, container killed" >&3
      exit 0
    fi
    [ "$idle_s" -gt 0 ] || continue
    cpu=$(sudo docker stats --no-stream --format '{{.CPUPerc}}' "$cname" 2>/dev/null | tr -d '%' || true)
    [ -n "$cpu" ] || continue
    if awk -v c="$cpu" 'BEGIN { exit !(c < 5.0) }'; then idle=$((idle + 60)); else idle=0; fi
    if [ "$idle" -ge "$idle_s" ]; then
      sudo docker kill "$cname" >/dev/null 2>&1 && echo "ygg-verify: IDLE ${idle_s}s under 5% CPU, container killed (a test is probably hung)" >&3
      exit 0
    fi
  done ) 3>&2 &
watchdog=$!
set +e
sudo nice -n 10 docker run --rm --name "$cname" --cpus="$cpus" --memory="$mem" \
  -v "$work:/src" -v /etc/machine-id:/etc/machine-id:ro \
  -v eureka-cargo-registry:/usr/local/cargo/registry -v eureka-nuget:/root/.nuget/packages \
  -v eureka-sccache:/sccache \
  -e BASH_ENV=/tmp/.ygg-bash-env \
  -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0='*' \
  $docker_args \
  -w /src "$image" bash -o pipefail -c "printf 'set -o pipefail\n' >/tmp/.ygg-bash-env; $cmd"
status=$?
set -e
pkill -P "$watchdog" 2>/dev/null || true
kill "$watchdog" 2>/dev/null || true
# Reap it. The subshell's own stderr is /dev/null, so killing its sleep
# prints no "Terminated" (agents misread that as a failed job); the TIMEOUT
# notice goes out through fd 3.
wait "$watchdog" 2>/dev/null || true
echo "ygg-verify: exit $status" >&2
echo "__YGG_VERDICT__ $status"
exit $status
REMOTE
) | {
  # The remote prints __YGG_VERDICT__ <status> as its last line. Strip it from the
  # output and exit with it. If it never arrives the remote script died before its
  # own exit line, so refuse to report a status that was never produced.
  verdict=97
  line=''
  while IFS= read -r line; do
    case "$line" in
      "__YGG_VERDICT__ "*) verdict=${line#__YGG_VERDICT__ }; continue ;;
    esac
    printf '%s\n' "$line"
  done
  if [ "$verdict" = 97 ]; then
    echo "ygg-verify: NO VERDICT from the remote job - treating as failure" >&2
    exit 97
  fi
  exit "$verdict"
}
