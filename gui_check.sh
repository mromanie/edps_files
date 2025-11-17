
#!/bin/bash

# Try to find the running process
running_pid=$(pgrep -f "edps-gui.*--port 7860")

if [ -n "$running_pid" ]; then
    echo "EDPS-GUI is running (PID: $running_pid)"

    . ~/bin/splash.txt
else
    echo "The EDPS GUI is not running. Start it with: gui_start"
fi
