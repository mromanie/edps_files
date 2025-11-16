#!/bin/bash

running=`ps -ef | grep jupyter | grep lab | grep -v grep`

if [[ -z "$running" ]]; then
  echo "Jupyter Lab is not running. Start it with: lab_start"
  echo
else
  URL="http://$(hostname -I | awk '{print $1}'):8888/lab"     
  echo "Access Jupyter Lab at ${URL}"
fi
