![o,age](https://i.postimg.cc/pdQFmfTj/prototypes.png)

With the convenience of a debian:bookworm docker container, `derivative-maker-docker` automatically verifies tags, updates source code and builds Whonix/Kicksecure images, incorporating the official derivative-maker build scripts, while including environment variables and intuitive ways to customize every available build option, container behavior and final build command. Additionally, log files of the entire build, git and key verification process are automatically generated. All necessary files already ship with the current derivative-maker source code, allowing for quick and simple deployment with a variety of pre-defined user scripts.

## Roadmap
- [x] Read documentation
- [ ] Install docker engine
- [ ] Clone derivative-maker
- [ ] Build the docker image
- [ ] Choose container parameters
- [ ] Craft a build command
- [ ] Deploy the container
    - [ ] Standard
    - [ ] Custom


## Script Overview
|  Name                                             | Description              | Location                                                                 
| --------------------------------------------------| -------------------------|------------|
| derivative-maker-docker-image | Builds the derivative-maker-docker image | host:derivative-maker/docker
| derivative-maker-docker-setup | Prepares minimal debian env in the docker image | container:/usr/bin
| derivative-maker-docker-run| Creates volumes and starts the container | host:derivative-maker/docker
| derivative-maker-docker-start| Verifies tag and executes any given build command  | container:/usr/bin
| entrypoint.sh | Initializes systemd and allows services to be started | container:/usr/bin

## Usage
- [x] Install docker engine
- [x] Build the docker image
### Docker Image
1. Locate your [desired tag](https://github.com/Whonix/derivative-maker/tags)
2. Clone it
   ```sh
   git clone --depth=1 --branch 17.3.9.9-stable --jobs=4 --recurse-submodules --shallow-submodules https://github.com/Whonix/derivative-maker.git
   ```
3. Build the docker image
   ```sh
   cd derivative-maker/docker 
   ```
   ```sh
   ./derivative-maker-docker-image
   ```
5. Verify successful image creation
   ```sh
   docker images
   ```
   <p align="right">(<a href="#readme-top">back to top</a>)</p>
### Container parameters
- [x] Choose container parameters
- [x] Craft a build command

|  Option     | Description              | Example Value                                                                 
| ------------| -------------------------|------------|
| `--tag`, `-t` | Builds a specific tag of your choosing | 17.3.9.9-stable
| `--build-step`, `-b` | Allows execution of specifc build-step |2800_create-lb-iso
| `--custom`, `-c` | Runs a custom command inside the container | /bin/bash
| `--git`, `-g`| Grants the ability to skip certain git commands  | none 
#### Sample Commands
1. Build with a custom tag
   ```sh
   ./derivative-maker-docker-run -t 17.3.9.9-stable <build arguments>
   ```
2. Execute specific build-step
   ```sh
   ./derivative-maker-docker-run -t 17.3.9.9-stable -b 2800_create-lb-iso <build arguments>
   ```
3. Running a custom command
   ```sh
   ./derivative-maker-docker-run -c /bin/bash
   ```
    <p align="right">(<a href="#readme-top">back to top</a>)</p>
