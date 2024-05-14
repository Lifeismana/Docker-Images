FROM python:3.8-slim as latest
RUN set -eux; \
# Install Red-DiscordBot dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # Red-DiscordBot
        build-essential \
        git \
    ; \
    rm -rf /var/lib/apt/lists/*;

RUN set -eux; \
    # create a venv
    python3.8 -m venv ~/reddashenv; \
    . ~/reddashenv/bin/activate; \
    pip install --upgrade pip; \
    pip install -U setuptools wheel;\
# Install Red-DiscordBot Dashboard dependencies
    pip install git+https://github.com/Lifeismana/Red-Dashboard.git\#egg=Red-Dashboard;
CMD ["bash", "-c", "source ~/reddashenv/bin/activate;reddash"]