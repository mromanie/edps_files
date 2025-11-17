#!/bin/bash

source ~/.bashrc > /dev/null

echo "Starting EDPS-GUI app..."

# Check if EDPS-GUI is already running
existing_pid=$(pgrep -f "edps-gui.*--port 7860")

if [ -n "$existing_pid" ]; then
    echo "EDPS-GUI is already running with PID: $existing_pid"
    echo "No action taken."
    exit 0
fi

# Set environment variables
export EDPSGUI_PDF_DIR=${HOME}/app/EDPS_GUI_PDF
export ADARI_REPORTS_DIR=/home/linuxbrew/.linuxbrew/share/esopipes/reports

# Activate virtual environment
source ~/python/venvs/edps/bin/activate

# Start EDPS-GUI in background
edps-gui \
  --plugins edpsgui.pdf_handler \
  --address 0.0.0.0 \
  --port 7860 \
  --basic-auth ${PANEL_AUTH} \
  --cookie-secret ${PANEL_COOKIE} \
  --admin \
  --allow-websocket-origin=* \
  > ~/app/edps_gui.log 2>&1 &

# Wait a moment for the process to fully start
sleep 1

# Find and save the actual Python process PID
actual_pid=$(pgrep -f "edps-gui.*--port 7860")
if [ -n "$actual_pid" ]; then
    echo $actual_pid > ~/app/edps_gui.pid
    echo "EDPS-GUI started with PID $actual_pid"
    echo "Log: ~/app/edps_gui.log"
else
    echo "Warning: Could not find EDPS-GUI process after starting"
    exit 1
fi

# Show splash screen
if [ -f ~/bin/splash.txt ]; then
    . ~/bin/splash.txt
fi
