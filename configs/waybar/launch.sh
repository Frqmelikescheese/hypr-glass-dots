#!/bin/bash

# Kill any existing waybar instances
pkill waybar

# Wait for pipewire
sleep 2

# Launch waybar
waybar &
