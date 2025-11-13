#!/bin/bash

# Display help message
show_help() {
  echo "Usage: $0 [parameter]"
  echo
  echo "Options:"
  echo "  -f, --from_scratch  Reinstall the edps venv from scratch"
  echo "  -h, --help          Show this help message"
  echo
  echo "If no parameter is provided, only pip install --upgrade is run."
}

# Install the dependencies from pip
pip_install() {
  . $HOME/python/venvs/edps/bin/activate
  python -m pip install --upgrade --no-cache-dir -r $HOME/app/requirements_edps.txt
  deactivate
}

# Reinstall the edps venv
venv_reinstall() {
  rm -rf $HOME/python/venvs/edps
  python -m venv $HOME/python/venvs/edps
}

#______________________________________________________________________________
# Check for help argument
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  show_help
  exit 0
fi

# Check if a parameter was provided
if [ -z "$1" ]; then
  echo "Just pip install..."
  pip_install
else
  if [ "$1" == "--from_scratch" ] || [ "$1" == "-f" ]; then
    echo "Removing and reinstalling the edps venv..."
    venv_reinstall
    pip_install
  else
    echo "Unknown parameter: $1"
    echo "Use -h or --help to see available options."
    exit 1
  fi
fi
