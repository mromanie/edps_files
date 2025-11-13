#!/bin/bash

running=`ps -ef | grep panel | grep -v grep`

if [[ -z "$running" ]]; then
  echo "The EDPS GUI is not running. Start it with: gui_start"
  echo
else
  . /home/user/bin/splash.txt
fi
