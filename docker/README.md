![o,age](https://i.postimg.cc/7Zw8684h/prototypes.png)

Utilizing the convenience of a debian:bookworm docker Container, `derivative-maker-docker` automatically verifies tags, updates source code and builds Whonix/Kicksecure images, incorporating the official `derivative-maker` build scripts, while including environment variables and intuitive ways to customize every available build option, container behavior and final build command. Additionally, log files of the entire build, git and key verification process are automatically generated. `derivative-maker-docker` already ships with the current `derivative-maker` source code, allowing for quick and simple deployment with a variety of pre-defined user scripts.

### Script Overview

|  Name                                             | Description              | Location                                                                 
| --------------------------------------------------| -------------------------|------------|
| `derivative-maker-docker-image` | Builds the derivative-maker-docker image | `host:derivative-maker/docker`
| `derivative-maker-docker-setup` | Prepares minimal debian env in the docker image | `container:/usr/bin`
| `derivative-maker-docker-run`| Creates volumes and starts the container | `host:derivative-maker/docker`
| `derivative-maker-docker-start`| Verifies tag and executes any given build command  | `container:/usr/bin`
| `entrypoint.sh` | Initializes systemd and allows services to be started | `container:/usr/bin`
