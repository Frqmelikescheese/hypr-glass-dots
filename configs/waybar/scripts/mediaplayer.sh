#!/bin/bash

# Simple script for Waybar custom/media
# Requirements: playerctl

playerctl --follow metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "class": "{{status}}", "tooltip": "{{artist}} - {{title}} ({{album}})"}'
