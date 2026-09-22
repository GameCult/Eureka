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
#   2. Clones it into a scratch work directory on Yggdrasil and checks the
#      commit out detached. It uses a real clone, not a worktree, because a
#      worktree's .git file points at a host path the container cannot see.
#   3. Runs <command> in <image> with a CPU and memory cap, niced, with one
#      shared registry cache per toolchain. The build output directory stays
#      inside the work directory, never shared between checkouts.
#   4. Removes the work directory unless KEEP=1, and exits with the job's status.
#
# At most $SLOTS jobs run at once on Yggdrasil, because it serves live
# traffic. The default cap for each job is 6 of its 16 CPUs and 16 GiB.
#
# EDITING: bash reads a running script from disk as it goes, so an in-place
# edit breaks every job still running it. One died with "unexpected EOF" on
# 2026-09-22. Write the new version to a temp file and rename it over this one.
#
# Usage (Git Bash on Starfire):
#   ygg-verify.sh <local-repo> <rev> <image> '<command>'
# Images:
#   rust    eureka-verify-rust   (rust 1.95 plus pwsh; built from rust.Dockerfile)
#   dotnet  mcr.microsoft.com/dotnet/sdk:10.0   (ships pwsh)
#   any other value is used as the image name as-is.
# The Eureka harness is copied to /harness/eureka-mutations.ps1 in the container.
# Example:
#   ygg-verify.sh /f/Projects/Huginn HEAD rust \
#     'cargo test --workspace && pwsh /harness/eureka-mutations.ps1 -Repo /src -Entries tools/eureka-cut10-mutations.psd1'
set -euo pipefail

repo=${1:?local repo}; rev=${2:?revision}; image=${3:?image}; cmd=${4:?command}
host=${YGG_HOST:-ygg}; cpus=${CPUS:-6}; mem=${MEM:-16g}; slots=${SLOTS:-2}
here=$(cd "$(dirname "$0")" && pwd)
harness="$here/../eureka-mutations.ps1"
sshopts=(-o BatchMode=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=4)

sha=$(git -C "$repo" rev-parse --verify "$rev^{commit}")
name=$(basename "$(git -C "$repo" rev-parse --show-toplevel)")
case "$image" in
  rust)   image=eureka-verify-rust ;;
  dotnet) image=mcr.microsoft.com/dotnet/sdk:10.0 ;;
esac

ssh "${sshopts[@]}" "$host" "mkdir -p ~/eureka-verify/repos ~/eureka-verify/work ~/eureka-verify/harness && \
  { test -d ~/eureka-verify/repos/$name.git || git init -q --bare ~/eureka-verify/repos/$name.git; }"
git -C "$repo" push -q "$host:eureka-verify/repos/$name.git" "$sha:refs/verify/$sha" --force
scp -q "$harness" "$host:eureka-verify/harness/eureka-mutations.ps1"
if [ "$image" = eureka-verify-rust ]; then
  scp -q "$here/rust.Dockerfile" "$host:eureka-verify/harness/rust.Dockerfile"
fi

# ssh joins its arguments into one string that the remote shell re-splits, so
# every argument is quoted here. Without it, `a && b` in the command runs b
# on the host.
remote_args=$(printf '%q ' "$name" "$sha" "$image" "$cpus" "$mem" "$slots" "${KEEP:-0}" "$cmd")
ssh "${sshopts[@]}" "$host" "bash -s -- $remote_args" <<'REMOTE'
set -euo pipefail
name=$1 sha=$2 image=$3 cpus=$4 mem=$5 slots=$6 keep=$7 cmd=$8
root=~/eureka-verify
if [ "$image" = eureka-verify-rust ] && ! sudo docker image inspect eureka-verify-rust >/dev/null 2>&1; then
  sudo nice -n 10 docker build -q -t eureka-verify-rust -f $root/harness/rust.Dockerfile $root/harness >/dev/null
fi
# Take whichever slot frees first. Waiting on one fixed slot while another
# freed stranded a job for over an hour on 2026-09-22.
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
  -v "$work:/src" -v "$root/harness:/harness:ro" -v /etc/machine-id:/etc/machine-id:ro \
  -v eureka-cargo-registry:/usr/local/cargo/registry -v eureka-nuget:/root/.nuget/packages \
  -e CARGO_TARGET_DIR=/src/target \
  -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0='*' \
  -w /src "$image" bash -c "$cmd"
status=$?
set -e
echo "ygg-verify: exit $status" >&2
exit $status
REMOTE
