#!/bin/bash

# Match by port number (more reliable)
running_pid=$(pgrep -f "jupyter-lab.*8888")

if [ -n "$running_pid" ]; then
    echo "Jupyter Lab is running (PID: $running_pid)"
    
    URL="http://$(hostname -I | awk '{print $1}'):8888/lab"
    echo "Access Jupyter Lab at ${URL}"
else
    echo "Jupyter Lab is not running"
fi
