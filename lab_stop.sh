#!/bin/bash

echo "Stopping Jupyter Lab..."

# Match by port number (more reliable)
running_pid=$(pgrep -f "jupyter-lab.*8888")

if [ -n "$running_pid" ]; then
    kill $running_pid
    sleep 2
    if pgrep -f "jupyter-lab.*8888" > /dev/null; then
        echo "Process didn't stop gracefully, force killing..."
        kill -9 $running_pid
    fi
    echo "Jupyter Lab stopped (PID: $running_pid)"
else
    echo "Jupyter Lab is not running"
fi

rm -f ~/app/jupyter.pid
