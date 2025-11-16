#!/bin/bash

# Start Panel app
echo "Starting Jupyter Lab..."

export PYTHONPATH=${HOME}/Notebooks/Utilities:${PYTHONPATH}
. ~/python/venvs/edps/bin/activate
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token=${PANEL_AUTH} > ~/app/jupyter.log 2>&1 &
deactivate
