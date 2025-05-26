# Use the official Ubuntu latest image as a parent image
#FROM ubuntu:latest
FROM nvidia/cuda:12.6.3-base-ubuntu24.04
# Set environment variables
# OLLAMA_HOST is set to 0.0.0.0 to allow connections from any IP address.
ENV OLLAMA_HOST=0.0.0.0
# OLLAMA_PORT is the default port Ollama listens on.
ENV OLLAMA_PORT=11434
# OLLAMA_MODELS is the directory where Ollama will store models.
# This will be inside the ollama user's home directory.
ENV OLLAMA_MODELS=/home/ollama/.ollama/models

# Arguments for user and group
ARG USERNAME=ollama
ARG USER_UID=999
ARG USER_GID=998

# Update package lists and install dependencies
# - ca-certificates: for HTTPS connections
# - curl: for downloading files
# - sudo: for allowing the ollama user to run commands if needed (though ideally not for the server itself)
#   (Note: sudo is generally not recommended for the final running process in a container,
#    but can be useful during setup or if specific ollama plugins/features might need it.
#    For a minimal server, it might not be strictly necessary after setup.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user and group
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} --create-home --shell /bin/bash ${USERNAME} && \
    # Optionally, add the user to the sudo group if you need sudo privileges for this user
    # For running ollama serve, sudo is not typically required by the ollama user itself.
    # usermod -aG sudo ${USERNAME} && \
    # echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${USERNAME} && \
    # chmod 0440 /etc/sudoers.d/${USERNAME}
    # Create the directory for Ollama models and set permissions
    # This step ensures the directory exists before Ollama tries to use it.
    mkdir -p /home/${USERNAME}/.ollama/models && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ollama

# Download and install Ollama (as root, because it installs to /usr/local/bin)
# The install script handles downloading and setting up the Ollama binary.
RUN curl -fsSL https://ollama.com/install.sh | sh

# Set the working directory to the ollama user's home
WORKDIR /home/${USERNAME}

# Switch to the non-root user
USER ${USERNAME}

# Expose the port Ollama runs on
EXPOSE ${OLLAMA_PORT}

# Define the entrypoint for the container
# This command starts the Ollama server as the 'ollama' user.
# Ollama will use /home/ollama/.ollama for its data.
CMD ["/usr/local/bin/ollama", "serve"]


