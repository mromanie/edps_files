#!/bin/bash

echo "Stopping EDPS-GUI..."

# Try to find the running process
running_pid=$(pgrep -f "edps-gui.*--port 7860")

if [ -n "$running_pid" ]; then
    # Process found, kill it
    kill $running_pid

    # Wait a moment and check if it's still running
    sleep 2
    if pgrep -f "edps-gui.*--port 7860" > /dev/null; then
        echo "Process didn't stop gracefully, force killing..."
        kill -9 $running_pid
    fi

    echo "EDPS-GUI stopped (PID: $running_pid)"
else
    echo "EDPS-GUI is not running"
fi

# Clean up PID file
if [ -f ~/app/edps_gui.pid ]; then
    rm ~/app/edps_gui.pid
    echo "PID file removed"
fi
