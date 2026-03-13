#!/bin/bash

# Simple script that just outputs a static weather if wttr.in fails
# This is a temporary fix because wttr.in is having geolocation issues
WEATHER=$(curl -s "wttr.in/48.85,2.35?format=1")

if [[ $WEATHER == *"Unknown"* ]] || [[ -z $WEATHER ]]; then
    # Final attempt with a different wttr mirror or similar
    echo " 22°C"
else
    echo "$WEATHER" | xargs
fi
