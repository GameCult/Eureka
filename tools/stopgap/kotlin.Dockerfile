# STOPGAP image for ygg-verify.sh: the Kotlin toolchain CultLib's
# packages/cultmesh-kotlin needs on Linux. JDK 21 plus kotlinc 2.2.21 (the
# version .github/workflows/cultnet-interop.yml pins) in /opt/kotlinc, Node 24
# for the TypeScript/Kotlin interop lane, and PowerShell 7 for build.ps1. It
# dies with ygg-verify.sh (see that file's deletion line). ygg-verify.sh tags
# the image by this file's hash, so an edit here rebuilds it.
#
# PowerShell comes from the GitHub release tarball, not Microsoft's apt repo:
# the temurin base is Ubuntu 26.04 and packages.microsoft.com has no powershell
# package for it (2026-09-30). Invariant globalization avoids the libicu
# dependency; build.ps1 does no culture-sensitive work.
FROM eclipse-temurin:21-jdk
RUN apt-get update \
 && apt-get install -y --no-install-recommends unzip curl ca-certificates git \
 && rm -rf /var/lib/apt/lists/*
RUN arch=$(dpkg --print-architecture | sed 's/amd64/x64/') \
 && mkdir -p /opt/microsoft/powershell \
 && curl -fsSL "https://github.com/PowerShell/PowerShell/releases/download/v7.5.11/powershell-7.5.11-linux-$arch.tar.gz" | tar -xz -C /opt/microsoft/powershell \
 && chmod +x /opt/microsoft/powershell/pwsh \
 && ln -s /opt/microsoft/powershell/pwsh /usr/local/bin/pwsh
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
RUN curl -fsSL https://github.com/JetBrains/kotlin/releases/download/v2.2.21/kotlin-compiler-2.2.21.zip -o /tmp/kotlinc.zip \
 && unzip -q /tmp/kotlinc.zip -d /opt \
 && rm /tmp/kotlinc.zip
ENV KOTLIN_HOME=/opt/kotlinc PATH=/opt/kotlinc/bin:$PATH
COPY --from=node:24 /usr/local /usr/local
