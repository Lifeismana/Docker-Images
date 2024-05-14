A docker image for Neuro Assassin's dashboard for Red-DiscordBot (probably not working)

Dashboard is available [here](https://github.com/Cog-Creators/Red-Dashboard)
This is highly inspired from PhasecoreX's docker image for Red-DiscordBot available [here](https://github.com/PhasecoreX/docker-red-discordbot)

I recommand to run it with Docker Compose

### Docker Compose

As with any Docker run command, you can also specify it as a docker-compose.yml file for easier management. Here is an example:

```yaml
version: "3.2"
services:
  red-dashboard:
    container_name: red-dashboard
    image: ghcr.io/lifeismana/docker-red-dashboard:latest
    restart: unless-stopped
    network_mode: host

```
