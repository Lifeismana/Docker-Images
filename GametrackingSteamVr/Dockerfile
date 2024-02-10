FROM debian:bookworm-slim AS base
RUN echo '\nAcquire::Retries "100";\nAcquire::https::Timeout "240";\nAcquire::http::Timeout "240";\nAPT::Install-Recommends "false";\nAPT::Install-Suggests "false";\n' > /etc/apt/apt.conf.d/99custom && \
    apt-get update && apt-get install -y \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

FROM golang:1.20 AS go
RUN git clone https://github.com/xPaw/elf-strings && \
    cd elf-strings && \
    go mod init elf-strings && \
    go get github.com/ianlancetaylor/demangle && \
    go build -o elf-strings

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS dotnet
ARG BUILDARCH
# https://stackoverflow.com/questions/70369368/check-architecture-in-dockerfile-to-get-amd-arm
RUN echo "BUILDARCH: $BUILDARCH" && \
    ARCH=$(echo $BUILDARCH | sed s/amd64/x64/) && \ 
    mkdir /data && \
    cd /data && \
    git clone --depth=1 https://github.com/SteamDatabase/ValveResourceFormat.git && \
    cd ValveResourceFormat && \
    dotnet build -c Release ./Decompiler/Decompiler.csproj && \
    dotnet publish --configuration Release -p:PublishSingleFile=true -p:DebugType=embedded --self-contained --runtime linux-${ARCH} Decompiler/Decompiler.csproj && \
    mv ./Decompiler/bin/Release/linux-${ARCH}/publish /data/Decompiler && \
    cd /data && \
    git clone https://github.com/SteamRE/SteamKit.git && \
    cd SteamKit && \
    dotnet build -c Release Resources/ProtobufDumper/ProtobufDumper/ProtobufDumper.csproj && \
    dotnet publish --configuration Release -p:PublishSingleFile=true -p:DebugType=embedded --self-contained --runtime linux-x64  Resources/ProtobufDumper/ProtobufDumper/ProtobufDumper.csproj && \
    cd /data && \
    git clone --depth=1 https://github.com/SteamRE/DepotDownloader.git && \
    cd DepotDownloader && \
    dotnet build -c Release ./DepotDownloader/DepotDownloader.csproj && \
    dotnet publish --configuration Release -p:PublishSingleFile=true -p:DebugType=embedded --self-contained --runtime linux-${ARCH} DepotDownloader/DepotDownloader.csproj && \
    mv ./DepotDownloader/bin/Release/net8.0/linux-${ARCH}/publish/DepotDownloader /data/DepotDownloader_export


FROM base AS download
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /data && \
    cd /data && \
    git clone https://github.com/Penguinwizzard/VPKTool.git && \
    cd VPKTool && \
    make

FROM base as main
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gnupg \
    binutils \
    nodejs \
    npm \
    php \
    php-common \
    php-mbstring \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# we're missing nm-with-macho so .dylib files won't work

COPY --from=go /go/elf-strings/elf-strings /data/elfstrings/elfstrings
COPY --from=dotnet /data/SteamKit/Resources/ProtobufDumper/ProtobufDumper/bin/Release/linux-x64/publish/ /data/ProtobufDumper
COPY --from=dotnet /data/Decompiler /data/ValveResourceFormat/Decompiler/bin/Release/linux-x64/publish/ 
COPY --from=download /data/VPKTool/vpktool /data/VPKTool/vpktool
COPY --from=dotnet /data/DepotDownloader_export /data/DepotDownloader/DepotDownloader
COPY list /data/list
COPY --chmod=755 script.sh /data/

WORKDIR /data

RUN useradd -m bot -d /data && chmod -R 755 /data && mkdir -p /data/.ssh && chmod 700 /data/.ssh && chown -R bot:bot /data

# I'll have to change this later
USER bot
RUN echo "|1|w1kVfoaNj+U3IraxC4lmklK2VWI=|Xbgg3EypjZkJ/NWTxDCQIpe42rw= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" >> /data/.ssh/known_hosts && \ 
echo ".DepotDownloader" >> /data/.gitignore && \
git config --global core.excludesfile ~/.gitignore && \
mkdir -p /data/.local/share/IsolatedStorage && \
mkdir -p /data/git_folder && \
mkdir -p /data/ValveProtobufs && \
echo "#!/bin/bash\necho \"HELLO I'M A GHOST \"" >> /data/ValveProtobufs/update.sh && \
chmod -R 755 /data/ValveProtobufs && \
chmod -R 755 /data/git_folder && \
chmod -R 755 /data/.local/share/IsolatedStorage
CMD [ "./script.sh" ]