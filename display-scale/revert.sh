#!/bin/sh
# Volta ao teste anterior: ambos a 100%.
set -e
kscreen-doctor output.DP-2.scale.1 output.DP-1.scale.1 output.DP-1.position.2560,72
kscreen-doctor -o | grep -E 'Output|Geometry|Scale'
