#!/bin/bash

source ~/.bashrc

echo "Starting Jupyter Lab..."

# Check if Jupyter is already running (use simpler pattern)
existing_pid=$(pgrep -f "jupyter-lab.*8888")

if [ -n "$existing_pid" ]; then
    echo "Jupyter Lab is already running with PID: $existing_pid"
    echo "No action taken."
    exit 0
fi

echo "Token: ${PANEL_AUTH:0:10}..."

export PYTHONPATH=${HOME}/Notebooks/Utilities:${PYTHONPATH}

source ~/python/venvs/edps/bin/activate

jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --ServerApp.token=${PANEL_AUTH} \
  > ~/app/jupyter.log 2>&1 &

sleep 1

actual_pid=$(pgrep -f "jupyter-lab.*8888")
if [ -n "$actual_pid" ]; then
    echo $actual_pid > ~/app/jupyter.pid
    echo "Jupyter Lab started with PID $actual_pid"
    echo "Log: ~/app/jupyter.log"
else
    echo "Warning: Could not find Jupyter process after starting"
    exit 1
fi
