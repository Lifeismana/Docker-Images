FROM mcr.microsoft.com/dotnet/sdk:6.0 AS dotnet
RUN mkdir /data && \
    cd /data && \
    git clone --depth=1 https://github.com/xPaw/SteamWebPipes.git && \
    cd SteamWebPipes && \
    dotnet build -c Release ./SteamWebPipes/SteamWebPipes.csproj && \
    dotnet publish --configuration Release -p:PublishSingleFile=true -p:DebugType=embedded --self-contained --runtime linux-x64 SteamWebPipes/SteamWebPipes.csproj

FROM debian:bookworm-slim
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libssl3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY --from=dotnet /data/SteamWebPipes/SteamWebPipes/bin/Release/linux-x64/publish /SteamWebPipes
CMD [ "/SteamWebPipes/SteamWebPipes" ]
