FROM debian:bookworm-slim AS base
RUN echo '\nAcquire::Retries "100";\nAcquire::https::Timeout "240";\nAcquire::http::Timeout "240";\nAPT::Install-Recommends "false";\nAPT::Install-Suggests "false";\n' > /etc/apt/apt.conf.d/99custom && \
    apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

FROM base AS builder
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    wget \
    golang-go && \
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0 && \
    mkdir /data && \
    cd /data && \
    git clone --depth=1 --recurse-submodules https://github.com/SteamDatabase/GameTracking.git && \
    cd GameTracking && \
    sed -i 's/git submodule update --remote --merge/git submodule update --init --remote --depth 1/' tools/build.sh && \
    sed -i 's/^git submodule update #/git submodule update --init #/' tools/build.sh && \
    ./tools/build.sh && \
    cd /data && \
    git clone --depth=1 https://github.com/SteamRE/DepotDownloader.git && \
    cd DepotDownloader && \
    dotnet build -c Release ./DepotDownloader/DepotDownloader.csproj && \
    dotnet publish --configuration Release -p:PublishSingleFile=true -p:DebugType=embedded --self-contained --runtime linux-x64 DepotDownloader/DepotDownloader.csproj && \
    mv ./DepotDownloader/bin/Release/net8.0/linux-x64/publish/DepotDownloader /data/DepotDownloader_export

FROM base AS main
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gnupg \
    nodejs \
    npm \
    php \
    php-common \
    php-mbstring \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /data/DepotDownloader_export /data/DepotDownloader/DepotDownloader
COPY --from=builder /data/GameTracking /data/GameTracking
COPY list /data/list
COPY --chmod=755 script.sh /data/

WORKDIR /data

RUN useradd -m bot -d /data -u 1001 && chmod -R 755 /data && chown -R bot:bot /data
USER bot

RUN mkdir -p /data/ValveProtobufs && \
echo "#!/bin/bash\necho \"HELLO I'M A GHOST \"" >> /data/ValveProtobufs/update.sh && \
chmod -R 755 /data/ValveProtobufs
CMD [ "/data/script.sh" ]