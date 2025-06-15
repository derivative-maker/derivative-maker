![o,age](https://i.postimg.cc/8zxYmSPV/prototypes.png)

With the convenience of a debian:bookworm docker container, `derivative-maker-docker` automatically verifies tags, updates source code and builds Whonix/Kicksecure images, incorporating the official derivative-maker build scripts, while including environment variables and intuitive ways to customize every available build option, container behavior and final build command. Additionally, log files of the entire build, git and key verification process are automatically generated. All necessary files already ship with the current derivative-maker source code, allowing for quick and simple deployment with a variety of pre-defined user scripts.

## Script Overview
|  Name                                             | Description              | Location                                                                 
| --------------------------------------------------| -------------------------|------------|
| derivative-maker-docker-image | Builds the derivative-maker-docker image | host:derivative-maker/docker
| derivative-maker-docker-setup | Prepares minimal debian env in the docker image | container:/usr/bin
| derivative-maker-docker-run| Creates volumes and starts the container | host:derivative-maker/docker
| derivative-maker-docker-start| Verifies tag and executes any given build command  | container:/usr/bin
| entrypoint.sh | Initializes systemd and allows services to be started | container:/usr/bin

## Usage
- [x] Clone derivative-maker tag
- [x] Build the docker image
- [x] Choose build parameters
- [x] Deploy the container
    - [x] Standard build
    - [ ] Custom Command
### Docker Image
1. Find the [latest available tag](https://github.com/Whonix/derivative-maker/tags)
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
3. (Optional) Pull the docker image
    ```sh
    docker pull derivative-maker/derivative-maker-docker:latest 
    ```
5. Verify successful image creation
   ```sh
   docker images
   ```
   <p align="right">(<a href="#readme-top">back to top</a>)</p>
