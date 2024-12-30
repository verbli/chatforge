#!/bin/bash


EC="$1"
MSG="$2"

if [[ "$EC" == "0" ]]; then
    /opt/gotify/bin/gotify push "[SUCCESS] $MSG"
    ffplay -autoexit /app/success.wav
elif [[ "$EC" == "-" ]]; then
    /opt/gotify/bin/gotify push "$MSG"
else
    /opt/gotify/bin/gotify push "[FAILED/$EC] $MSG"
    ffplay -autoexit /app/failure.wav
fi

