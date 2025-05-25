#!/bin/bash

# Configuration
# Name of the Ollama container (must match your docker-compose.yml)
OLLAMA_CONTAINER_NAME="ollama-container-ollama"
# Path to ollama binary inside the container
OLLAMA_CONTAINER_BIN="/usr/local/bin/ollama"

# Function to display usage
usage() {
  echo "Usage: $0 <model_name> [additional_ollama_run_arguments]"
  echo ""
  echo "Description:"
  echo "  Runs an Ollama model interactively inside the Docker container."
  echo ""
  echo "Arguments:"
  echo "  <model_name>                 - The name of the Ollama model to run (e.g., llama2, mistral)"
  echo "  [additional_ollama_run_arguments] - Any further arguments to pass to 'ollama run' (e.g., a prompt)"
  echo ""
  echo "Examples:"
  echo "  $0 llama2"
  echo "  $0 mistral \"Tell me a joke.\""
  echo "  $0 codellama:7b-code \"function factorial(n) {\""
}

# Check if a model name is provided
if [ -z "$1" ]; then
  echo "Error: Model name is required."
  usage
  exit 1
fi

MODEL_NAME="$1"
# Shift arguments so "$@" now contains arguments from the 2nd one onwards
shift

echo "Attempting to run Ollama model '$MODEL_NAME' in container '$OLLAMA_CONTAINER_NAME'..."

# Execute the ollama run command inside the container
# "$@" passes all remaining arguments (from $2 onwards) to the ollama run command
docker exec -it "$OLLAMA_CONTAINER_NAME" "$OLLAMA_CONTAINER_BIN" run "$MODEL_NAME" "$@"

if [ $? -eq 0 ]; then
  echo "Ollama model session ended."
else
  echo "Error: Failed to run Ollama model. Ensure the container is running and the model is pulled."
fi

