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
#   4. Removes the work directory unless KEEP=1, and exits with the job's status.
#
# At most $SLOTS jobs run at once on Yggdrasil, because it serves live
# traffic. The default cap for each job is 4 of its 16 CPUs and 12 GiB, the
# policy the operator ruled for Idunn verify (Q-V6).
#
# There is no hand-written mutation harness: the operator retired it on
# 2026-09-22. Mutation testing uses the ecosystem's tools on a cut's diff.
#
# EDITING: bash reads a running script from disk as it goes, so editing this
# file in place breaks every job still running it (one died with "unexpected
# EOF", 2026-09-22). Write the new version to a temp file and rename it over
# this one.
#
# Usage (Git Bash on Starfire):
#   ygg-verify.sh <local-repo> <rev> <image> '<command>'
# Images:
#   rust    eureka-verify-rust:<Dockerfile hash>   (rust 1.95 plus cargo-mutants)
#   dotnet  mcr.microsoft.com/dotnet/sdk:10.0   (install Stryker in the command:
#           dotnet tool install -g dotnet-stryker)
#   any other value is used as an image name as-is.
# Example:
#   ygg-verify.sh /f/Projects/Huginn HEAD rust \
#     'cargo test --workspace && git diff BASE HEAD > /tmp/d && cargo mutants --in-diff /tmp/d'
set -euo pipefail

repo=${1:?local repo}; rev=${2:?revision}; image=${3:?image}; cmd=${4:?command}
host=${YGG_HOST:-ygg}; cpus=${CPUS:-4}; mem=${MEM:-12g}; slots=${SLOTS:-2}
here=$(cd "$(dirname "$0")" && pwd)
sshopts=(-o BatchMode=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=4)

sha=$(git -C "$repo" rev-parse --verify "$rev^{commit}")
name=$(basename "$(git -C "$repo" rev-parse --show-toplevel)")
case "$image" in
  rust)   image=eureka-verify-rust:$(sha256sum "$here/rust.Dockerfile" | cut -c1-12) ;;
  dotnet) image=mcr.microsoft.com/dotnet/sdk:10.0 ;;
esac

ssh "${sshopts[@]}" "$host" "mkdir -p ~/eureka-verify/repos ~/eureka-verify/work ~/eureka-verify/images && \
  { test -d ~/eureka-verify/repos/$name.git || git init -q --bare ~/eureka-verify/repos/$name.git; }"
git -C "$repo" push -q "$host:eureka-verify/repos/$name.git" "$sha:refs/verify/$sha" --force
case "$image" in
  eureka-verify-rust:*) scp -q "$here/rust.Dockerfile" "$host:eureka-verify/images/rust.Dockerfile" ;;
esac

# ssh joins its arguments into one string that the remote shell splits again,
# so every argument is quoted here. Without that, `a && b` in the command runs
# b on the host.
remote_args=$(printf '%q ' "$name" "$sha" "$image" "$cpus" "$mem" "$slots" "${KEEP:-0}" "$cmd")
ssh "${sshopts[@]}" "$host" "bash -s -- $remote_args" <<'REMOTE'
set -euo pipefail
name=$1 sha=$2 image=$3 cpus=$4 mem=$5 slots=$6 keep=$7 cmd=$8
root=~/eureka-verify
case "$image" in
  eureka-verify-rust:*)
    if ! sudo docker image inspect "$image" >/dev/null 2>&1; then
      sudo nice -n 10 docker build -q -t "$image" -f "$root/images/rust.Dockerfile" "$root/images" >/dev/null
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
set +e
sudo nice -n 10 docker run --rm --cpus="$cpus" --memory="$mem" \
  -v "$work:/src" -v /etc/machine-id:/etc/machine-id:ro \
  -v eureka-cargo-registry:/usr/local/cargo/registry -v eureka-nuget:/root/.nuget/packages \
  -e CARGO_TARGET_DIR=/src/target \
  -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0='*' \
  -w /src "$image" bash -c "$cmd"
status=$?
set -e
echo "ygg-verify: exit $status" >&2
exit $status
REMOTE
