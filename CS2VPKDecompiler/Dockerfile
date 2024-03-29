FROM debian:bookworm-slim AS base
RUN echo '\nAcquire::Retries "100";\nAcquire::https::Timeout "240";\nAcquire::http::Timeout "240";\nAPT::Install-Recommends "false";\nAPT::Install-Suggests "false";\n' > /etc/apt/apt.conf.d/99custom && \
    apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS dotnet
ARG BUILDARCH
# https://stackoverflow.com/questions/70369368/check-architecture-in-dockerfile-to-get-amd-arm
RUN echo "BUILDARCH: $BUILDARCH" && \
    ARCH=$(echo $BUILDARCH | sed s/amd64/x64/) && \ 
    mkdir /data && \
    cd /data && \
    git clone --depth=1  https://github.com/SteamDatabase/ValveResourceFormat.git && \
    cd ValveResourceFormat && \
    dotnet build -c Release ./Decompiler/Decompiler.csproj && \
    dotnet publish --configuration Release -p:PublishSingleFile=true -p:DebugType=embedded --self-contained --runtime linux-${ARCH} Decompiler/Decompiler.csproj && \
    mv ./Decompiler/bin/Release/linux-${ARCH}/publish /data/Decompiler && \
    cd /data && \
    git clone --depth=1 https://github.com/SteamRE/DepotDownloader.git && \
    cd DepotDownloader && \
    dotnet build -c Release ./DepotDownloader/DepotDownloader.csproj && \
    dotnet publish --configuration Release -p:PublishSingleFile=true -p:DebugType=embedded --self-contained --runtime linux-${ARCH} DepotDownloader/DepotDownloader.csproj && \
    mv ./DepotDownloader/bin/Release/net8.0/linux-${ARCH}/publish/DepotDownloader /data/DepotDownloader_export

FROM base as main
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gawk \
    gnupg \
    php \
    php-common \
    php-mbstring \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*
COPY --from=dotnet /data/Decompiler /data/Decompiler/ 
COPY --from=dotnet /data/DepotDownloader_export /data/DepotDownloader/DepotDownloader



WORKDIR /data

RUN useradd -m bot -d /data && chmod -R 755 /data && mkdir -p /data/.ssh && chmod 700 /data/.ssh && chown -R bot:bot /data
USER bot
RUN echo ".DepotDownloader" >> /data/.gitignore && \
git config --global core.excludesfile ~/.gitignore && \
mkdir -p /data/.local/share/IsolatedStorage && \
mkdir -p /data/git_folder

ENV PATH=/data/.venv/bin:$PATH

COPY --chmod=777 files/script.sh /data/script.sh
COPY --chmod=777 files/fix_encoding /data/fix_encoding
COPY --chmod=777 files/vpk.txt /data/vpk.txt

CMD ["/data/script.sh"]