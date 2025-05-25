#!/bin/bash

DOCKER_COMPOSE_FILE="./ollama-docker/docker-compose.yaml"
OLLAMA_DATA_DIR="/opt/app/ollama-container/ollama_data"
OLLAMA_SERVICE_NAME="ollama"
OLLAMA_CONTAINER_NAME="ollama-container-ollama" # Added for docker exec

# Function to display usage
usage() {
  echo "Usage: $0 [option]"
  echo ""
  echo "Options:"
  echo "  start               - Start the Ollama container (builds if necessary)"
  echo "  stop                - Stop the Ollama container"
  echo "  run <model_name>    - Run an Ollama model (interactive session)" # Added run option
  echo "  help                - Display this help message"
  echo ""
  echo "Examples:"
  echo "  $0 start"
  echo "  $0 stop"
  echo "  $0 run llama2" # Added run example
}

# Function to ensure the data directory exists
ensure_data_dir() {
  if [ ! -d "$OLLAMA_DATA_DIR" ]; then
    echo "Creating Ollama data directory: $OLLAMA_DATA_DIR"
    sudo mkdir -p "$OLLAMA_DATA_DIR" || { echo "Error: Failed to create $OLLAMA_DATA_DIR. Check permissions."; exit 1; }
    # Set permissions so the Ollama user inside the container can write to it
    # This sets ownership to the current user running the script.
    # You may need to manually adjust ownership/permissions if models fail to download
    # inside the container due to user ID mismatches.
    sudo chown -R $(id -u):$(id -g) "$OLLAMA_DATA_DIR"
    echo "Ensure that the user running inside the container has write permissions to $OLLAMA_DATA_DIR."
  fi
}


# Main script logic
case "$1" in
  start)
    ensure_data_dir
    echo "Starting Ollama container..."
    # 'up --build -d' will build the image if it's new or changed,
    # and then start the container in detached mode.
    docker compose -f "$DOCKER_COMPOSE_FILE" up --build -d "$OLLAMA_SERVICE_NAME"
    if [ $? -eq 0 ]; then
      echo "Ollama container started successfully."
    else
      echo "Error: Failed to start Ollama container."
    fi
    ;;
  stop)
    echo "Stopping Ollama container..."
    # 'down' will stop and remove the container and its associated network.
    # The volume data at /opt/app/ollama_data will be preserved.
    docker compose -f "$DOCKER_COMPOSE_FILE" down "$OLLAMA_SERVICE_NAME"
    if [ $? -eq 0 ]; then
      echo "Ollama container stopped."
    else
      echo "Error: Failed to stop Ollama container."
    fi
    ;;
  run) # New 'run' command logic
    if [ -z "$2" ]; then
      echo "Error: Model name required for 'run' command."
      usage
      exit 1
    fi
    echo "Running Ollama model: $2 (interactive session)..."
    # Execute the ollama run command inside the container
    docker exec -it "$OLLAMA_CONTAINER_NAME" /usr/local/bin/ollama run "$2" "${@:3}"
    ;;
  help)
    usage
    ;;
  *)
    echo "Invalid option: $1"
    usage
    exit 1
    ;;
esac

