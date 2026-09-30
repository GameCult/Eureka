# STOPGAP image for ygg-verify.sh: Rust plus cargo-mutants, the ecosystem
# mutation tool Soul runs on a cut's diff, plus the Windows GNU std so a job can
# `cargo check --target x86_64-pc-windows-gnu` without downloading it. It dies
# with ygg-verify.sh (see that file's deletion line). ygg-verify.sh tags the
# image by this file's hash, so an edit here rebuilds it.
#
# sccache (2026-09-30): every job clones fresh and builds into an empty
# /src/target, so a job cannot pick up another checkout's stale output (cargo
# decides by mtime). That made every run, rerun, Soul pass and mutant a cold
# build. sccache caches rustc outputs by the hash of their inputs, not by mtime,
# so sharing its cache between checkouts cannot hand one tree another's build.
# ygg-verify.sh mounts the shared cache at /sccache. Incremental compilation is
# off because sccache does not cache incremental crates.
FROM rust:1.95-bookworm
RUN rustup target add x86_64-pc-windows-gnu
RUN cargo install --locked cargo-mutants \
 && cargo install --locked --no-default-features sccache --version 0.18.0 \
 && rm -rf /usr/local/cargo/registry
ENV RUSTC_WRAPPER=/usr/local/cargo/bin/sccache \
    SCCACHE_DIR=/sccache \
    SCCACHE_CACHE_SIZE=60G \
    CARGO_INCREMENTAL=0
