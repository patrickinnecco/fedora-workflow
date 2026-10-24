#!/bin/sh
# Volta o atalho do ChatGPT para XWayland (padrão do app).
set -e
dir=$(dirname "$(readlink -f "$0")")
install -Dm644 "$dir/chatgpt.desktop.original" "$HOME/.local/share/applications/chatgpt.desktop"
kbuildsycoca6 >/dev/null 2>&1 || true
echo "Revertido."
