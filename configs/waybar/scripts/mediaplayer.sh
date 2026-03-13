#!/bin/bash
while true; do
  player_status=$(playerctl status 2>/dev/null)
  if [ "$player_status" = "Playing" ]; then
    echo "$(playerctl metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "class": "{{status}}"}')"
  elif [ "$player_status" = "Paused" ]; then
    echo "$(playerctl metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "class": "{{status}}"}')"
  else
    echo '{"text": "No Media", "alt": "Stopped", "class": "Stopped"}'
  fi
  sleep 1
done
