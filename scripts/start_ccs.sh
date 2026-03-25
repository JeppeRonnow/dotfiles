#!/bin/bash
CCS_IMAGE="docker.io/library/ubuntu:20.04"
CCS_CONTAINER="my-ccs"

create_container() {
  echo "Creating container..."
  mkdir -p /home/jeppe/work/CCSworkspace
  podman run -d \
    --name "$CCS_CONTAINER" \
    --network host \
    -e DISPLAY="$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /home/jeppe/ti:/home/jeppe/ti \
    -v /home/jeppe/Downloads:/home/jeppe/Downloads \
    -v /home/jeppe/work/CCSworkspace:/home/jeppe/work/CCSworkspace \
    --device /dev/bus/usb \
    --privileged \
    "$CCS_IMAGE" \
    sleep infinity
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create container."
    exit 1
  fi
  echo "Container created."
}

STATUS=$(podman inspect "$CCS_CONTAINER" --format '{{.State.Status}}' 2>/dev/null)
if [ -z "$STATUS" ]; then
  echo "Container does not exist. Creating..."
  create_container
elif [ "$STATUS" = "exited" ] || [ "$STATUS" = "stopped" ]; then
  echo "Container exited. Restarting..."
  podman start "$CCS_CONTAINER" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "Start failed. Recreating..."
    podman rm -f "$CCS_CONTAINER"
    create_container
  fi
elif [ "$STATUS" = "running" ]; then
  echo "Container already running."
else
  echo "Unknown state: $STATUS. Recreating..."
  podman rm -f "$CCS_CONTAINER"
  create_container
fi

echo "Allowing X connections from local..."
xhost +local:

echo "Dropping into container terminal..."
podman exec -it -e DISPLAY="$DISPLAY" "$CCS_CONTAINER" bash
