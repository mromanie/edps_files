#!/bin/bash

# Start Panel app
echo "Starting EDPS-GUI app..."
gui=$(find /home/user -name 'edps-gui.py')

source /home/user/python/venvs/edps/bin/activate
panel serve $gui \
      --plugins edpsgui.pdf_handler \
      --address 0.0.0.0 \
      --port 5006 \
      --prefix /panel \
      --allow-websocket-origin='*' \
      >& /home/user/app/edps-gui.log \
    &
deactivate

. /home/user/bin/splash.txt
