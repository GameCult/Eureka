# STOPGAP image for ygg-verify.sh: Rust plus cargo-mutants, the ecosystem
# mutation tool Soul runs on a cut's diff. It dies with ygg-verify.sh (see that
# file's deletion line). ygg-verify.sh tags the image by this file's hash, so an
# edit here rebuilds it.
FROM rust:1.95-bookworm
RUN cargo install --locked cargo-mutants && rm -rf /usr/local/cargo/registry
