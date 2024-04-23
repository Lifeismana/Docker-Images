FROM phasecorex/red-discordbot:full as latest

RUN apt-get update; \
    apt-get install -y --no-install-recommends \
        libaio1 \
        libaio-dev \
        dirmngr \
        curl \
    ; \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash;\
    apt-get install speedtest; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /config/.config/ookla; \
    echo ewogICAgIlNldHRpbmdzIjogewogICAgICAgICJMaWNlbnNlQWNjZXB0ZWQiOiAiNjA0ZWMyN2Y4Mjg0NTYzMzFlYmY0NDE4MjYyOTJjNDkyNzZiZDNjMWJlZTFhMmY2NWE2NDUyZjUwNWM0MDYxYyIsCiAgICAgICAgIkdEUFJUaW1lU3RhbXAiOiAxNjgyNTUyMzUzCiAgICB9Cn0= | base64 -d - > /config/.config/ookla/speedtest-cli.json;