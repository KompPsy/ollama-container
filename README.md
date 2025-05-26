# ollama-container

## Description
This package contains a set of Dockerfile, Docker Compose and Scripts on a Linux system environment.

## Prerequisites
Before running the installation scripts, ensure your system meets the following requirements:

1.  **Operating System:** A Linux distribution. The scripts have specific support for:
    * Debian-based systems (Debian, Ubuntu, etc.)
    * RHEL-based systems (CentOS, Fedora, Rocky Linux, Amazon Linux, etc.)
    * WSL2 (Windows Subsystem for Linux 2) is supported, but GPU passthrough requires specific configuration. WSL1 is *not* supported.
2.  **Architecture:** amd64 (x86_64) or arm64 (aarch64).
3.  **Internet Connection:** Required to download Ollama, Docker images, GPU drivers, and dependencies.
4.  **Permissions:** You will need `sudo` privileges or root access to run the installation scripts, as they install software, manage services, and modify user groups.
5.  **Docker and Docker Compose:** Run this script below to install all the needed docker related packages below:

    ```bash
    curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/main/install-docker.sh | sudo bash 
 ``

6.  **(Optional) GPU:**
     **NVIDAIA** Compatible NVIDIA GPU with appropriate drivers. The curl -fsSL https://ollama.com/install.sh | sh inside the docker compose is used script attempts to detect and install CUDA drivers if needed (requires `lspci` or `lshw` to be installed for detection).
     **NVIDIA Container Toolkit Installation** :
      ### Install with Apt:
      #### Configure the repository

    ```bash
   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
   curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   sudo apt-get update
        ```

      ### Install the NVIDIA Container Toolkit packages
        ```
sudo apt-get install -y nvidia-container-toolkit
   ``
Install with Yum or Dnf

Configure the repository:
    ```bash
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo \
    | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
Install the NVIDIA Container Toolkit packages
sudo yum install -y nvidia-container-toolkit
    ```
Configure Docker to use Nvidia driver

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

    * **AMD:** Compatible AMD GPU. The `install-ollama.sh` script attempts to detect and install ROCm components if needed (requires `lspci` or `lshw` to be installed for detection).
      
## Ollama Docker Compose Configuration

File Path:
    ```bash
    ./ollama-container/ollama-docker/docker-compose.yaml
        ```

This `docker-compose.yml` file defines and configures a service named `ollama` to run Ollama in a Docker container.

---
## Overview
The configuration sets up an Ollama instance with specific settings for **resource management**, **model storage**, and **operational behavior**.

---
## Service: `ollama`

### Build:
It builds a Docker image using a `Dockerfile` located in the current directory (`.`).

### Container Name:
The running container will be named `ollama-container-ollama`.

### Ports:
It maps port `11435` on the host machine to port `11434` inside the container. This means you can access the Ollama API (which typically runs on port `11434`) via `http://localhost:11435` on your host machine.

### Volumes:
It mounts a host directory (`/opt/app/ollama-container/ollama_data`) to `/home/ollama/.ollama/models` inside the container. This is crucial for **persisting Ollama models**.

**Note**: The line `# - /opt/app/ollama-container/ollama_data:/usr/share/ollama/.ollama/models` is commented out, indicating an alternative or previous model storage path. The active path is `/home/ollama/.ollama/models`.

**Important**: You must ensure the host directory `/opt/app/ollama-container/ollama_data` exists and has the necessary permissions for Docker to write to it.

### Environment Variables:
* `PATH=$PATH`: Inherits the `PATH` variable from the environment where `docker-compose` is executed.
* `OLLAMA_MODEL_CACHE_SIZE=21474836480`: Sets the model cache size to approximately **20GB** (21,474,836,480 bytes).
* `OLLAMA_HOST=0.0.0.0`: Configures Ollama to listen on all available network interfaces within the container, making it accessible via the mapped port.
* `OLLAMA_CUDA=1`: Enables **CUDA support**, suggesting the container is intended to run on a host with NVIDIA GPUs for accelerated performance. 🚀
* `OLLAMA_MAX_LOADED=2`: Specifies the maximum number of models that can be loaded into memory concurrently.
* `OLLAMA_CONTINUOUS_BATCHING=true`: Enables **continuous batching** for potentially improved throughput.
* `OLLAMA_MODEL_LOADER=vllm`: Specifies `vllm` as the model loader, which is an engine for fast LLM inference and serving.
* `OLLAMA_VLLM_MAX_MEMORY_PER_GPU=15.9`: Sets the maximum GPU memory (in GB) to be used by vLLM per GPU.
* `OLLAMA_LOG_LEVEL=debug`: Sets the Ollama application's log level to `debug` for more verbose output.
* `OLLAMA_FLASH_ATTENTION=1`: Enables **FlashAttention**, an optimization for attention mechanisms in transformer models.
* `OLLAMA_ORIGINS=*`: Allows requests from any origin (CORS setting). This is permissive and might need to be restricted in a production environment. ⚠️
* `OLLAMA_DISABLE_MMAP=false`: Ensures memory mapping is enabled, which can be important for performance.

### Restart Policy:
`restart: unless-stopped`: The container will automatically restart if it crashes or stops, unless it was explicitly stopped by the user.

---
## Usage
To run this configuration:

1.  Ensure you have **Docker** and **Docker Compose** installed.
2.  Create a `Dockerfile` in the same directory as this `docker-compose.yml` file, tailored to set up Ollama.
3.  Create the host directory for model storage:
    ```bash
    mkdir -p /opt/app/ollama-container/ollama_data
    ```
    (and ensure appropriate permissions).
4.  Navigate to the directory containing the `docker-compose.yml` file in your terminal.
5.  Run the command:
    ```bash
    docker-compose up -d
    ```
    (the `-d` flag runs it in detached mode).

To stop the service:

```bash
docker-compose down


# Ollama Docker Management Script

## Script Summary

File Path:
    ```bash
    ./ollama-container/ollama.sh
        ```

This bash script, `ollama.sh`, is designed to simplify the management of an Ollama instance running inside a Docker container. It provides commands to start, stop, and interact with the Ollama service. The script ensures that the necessary data directory for Ollama models exists and attempts to set appropriate permissions. It utilizes a Docker Compose file located at `./ollama-docker/docker-compose.yaml` to define and manage the Ollama service.

Key functionalities include:

* **Starting Ollama:** It can build the Docker image if it's new or has changed and then start the Ollama container in detached mode.
* **Stopping Ollama:** It can stop and remove the Ollama container and its associated network, while preserving the model data stored in a volume.
* **Running Models:** It allows users to run a specific Ollama model in an interactive session within the running container.
* **Data Directory Management:** It checks for the existence of the Ollama data directory (`/opt/app/ollama-container/ollama_data`) and creates it if it's missing, also attempting to set the correct ownership.
* **Help Information:** It provides a help message detailing the available commands and their usage.

## Usage

The script is executed from the command line, followed by an option specifying the desired action.

```bash
./ollama.sh [option]
        ```
# ollama-container
