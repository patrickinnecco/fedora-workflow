#!/bin/sh
# 1440p (DP-2) a 125% e 1080p (DP-1) a 100%, lado a lado sem vão e com bordas inferiores alinhadas.
# Com DP-2 a 1.25 a largura lógica é 2048 e a altura 1152; 1152 - 1080 = 72.
set -e
kscreen-doctor output.DP-2.scale.1.25 output.DP-1.scale.1 output.DP-1.position.2048,72
kscreen-doctor -o | grep -E 'Output|Geometry|Scale'
