# STOPGAP image for ygg-verify.sh: Rust plus PowerShell, so the Eureka mutation
# harness can run cargo suites. It dies with ygg-verify.sh (see that file's
# deletion line).
FROM rust:1.95-bookworm
ARG PWSH_VERSION=7.5.3
RUN curl -fsSL -o /tmp/pwsh.tar.gz \
      "https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-x64.tar.gz" \
 && mkdir -p /opt/pwsh && tar -xzf /tmp/pwsh.tar.gz -C /opt/pwsh && rm /tmp/pwsh.tar.gz \
 && chmod +x /opt/pwsh/pwsh && ln -s /opt/pwsh/pwsh /usr/local/bin/pwsh
