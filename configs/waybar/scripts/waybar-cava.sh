#!/bin/bash

# Define the icons for the visualizer
bar="  ▂▃▄▅▆▇█"
dict="s/;//g;"

# Create the sed replacement string
for i in {0..7}; do
    dict+="s/$i/${bar:$i:1}/g;"
done

# Run cava and pipe it through sed for the visualizer effect
cava -p ~/.config/waybar/cava_config | sed -u "$dict"
