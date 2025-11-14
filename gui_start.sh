#!/bin/bash

# Start Panel app
echo "Starting EDPS-GUI app..."
gui=$(find /opt/cloudadm -name 'edps-gui.py')

source /opt/cloudadm/python/venvs/edps/bin/activate
panel serve $gui \
      --plugins edpsgui.pdf_handler \
      --address 0.0.0.0 \
      --port 5006 \
      --prefix /panel \
      --allow-websocket-origin='*' \
      >& /opt/cloudadm/app/edps-gui.log \
    &
deactivate

. /opt/cloudadm/bin/splash.txt
