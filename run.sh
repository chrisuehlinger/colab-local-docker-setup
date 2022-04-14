#!/bin/bash -ex

# This makes sure we can kill the process if we press Ctrl+C.
# If Ctrl+C still doesn't work, run this in another terminal window: docker kill "$(docker ps -q)"
close_it_down(){
    docker kill "$(docker ps -q)"
}
trap "close_it_down" SIGINT

# Build the docker image (completes instantly if you haven't made any changes to the Dockerfile)
time docker build -t colab-local:latest .

# Remove any layers of old images that are no longer referenced,
# this is really important since these layers can take up a lot of space
time docker system prune -f

# Create an output directory for the container
mkdir -p output
if [ -z "$JUPYTER_PASSWORD_FOR_COLAB" ]
then
      echo "Set a password by running: export JUPYTER_PASSWORD_FOR_COLAB='whateverthepasswordis'"
else
    # Run the docker image
    docker run --rm \
        --gpus all \
        --shm-size=1g \
        --ulimit memlock=-1 \
        -p 8081:8081 \
        -e "JUPYTER_PASSWORD_FOR_COLAB=${JUPYTER_PASSWORD_FOR_COLAB}" \
        -v "$(pwd)/output:/content/images_out" \
        colab-local:latest &
    
    wait
fi
