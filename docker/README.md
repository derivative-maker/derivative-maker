![o,age](https://i.postimg.cc/VsxgCNmv/prototypes.png)

With the convenience of a debian:bookworm docker container, `derivative-maker-docker` automatically verifies tags, updates source code and builds Whonix/Kicksecure images, incorporating the official derivative-maker build scripts, while including environment variables and intuitive ways to customize every available build option, container behavior and final build command. Additionally, log files of the entire build, git and key verification process are automatically generated. All necessary files already ship with the current derivative-maker source code, allowing for quick and simple deployment with a variety of pre-defined user scripts.

## Roadmap
- [x] Read documentation
- [ ] Install docker engine
- [ ] Clone derivative-maker
- [ ] Build the docker image
- [ ] Choose volume folders
- [ ] Choose container parameters
- [ ] Craft a build command
- [ ] Deploy the container
    - [ ] Standard
    - [ ] Custom


## Script Overview
|  Name                                             | Description              | Location                                                                 
| --------------------------------------------------| -------------------------|------------|
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
3. The docker image is automatically generated
  + Checking image status
    ```sh
    docker images
    ```
  + Trigger re-creation by deleting the current image
    ```
    docker rmi -f derivative-maker/derivative-maker-docker:latest
    ```
### Volumes
1. By default 2 folders are generated in the user's home directory
   ```sh
   BINARY_VOLUME="$HOME/binary_mnt"
   CACHER_VOLUME="$HOME/approx_cache_mnt"
   ```
  + `BINARY_VOLUME` is the location of build artifacts and logs 
  + `CACHER_VOLUME` is the mount point of the container's `/var/cache/apt-cacher-ng`
2. To change folder names or locations use the container param `--mount`
### Container parameters
- [x] Choose container parameters
- [x] Craft a build command

|  Option     | Description              | Sample Value                                                                 
| ------------| -------------------------|------------|
| `--tag`, `-t` | Build a specific tag of your choosing | 17.3.9.9-stable
| `--build-step`, `-b` | Allow execution of a specifc build-step |2800_create-lb-iso
| `--custom`, `-c` | Run a custom command inside the container | /bin/bash
| `--git`, `-g`| Skip git pull to preserve current state  | none 
| `--mount`, `-m`| Choose custom volume mount points  | /home/user/whonix 
#### Sample Commands
1. Build with a custom tag
   ```sh
   ./derivative-maker-docker-run -t 17.3.9.9-stable -- <build arguments>
   ```
2. Execute specific build-steps
   ```sh
   ./derivative-maker-docker-run -t 17.3.9.9-stable -b 2800_create-lb-iso -- <build arguments>
   ```
3. Running a custom command
   ```sh
   ./derivative-maker-docker-run -c /bin/bash --
   ```
4. Choose custom volume mount points
   ```sh
   ./derivative-maker-docker-run -t 17.3.9.9-stable -m /home/user/whonix /home/user/apt-cache -- <build arguments>
   ```
  + The first argument denotes the binary volume while the second refers to apt-cacher
#### Hints
* Without usage of `--tag`, the latest tag is automatically chosen
* `--tag master` is possible and builds directly from master branch
* Multiple custom commands can be chained with `&&` or `;`
* Using end of options `--` is recommended
