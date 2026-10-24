#!/bin/sh
# Instala o atalho do ChatGPT em Wayland nativo (com IME do fcitx). Reinicie o ChatGPT depois.
set -e
dir=$(dirname "$(readlink -f "$0")")
dest="$HOME/.local/share/applications/chatgpt.desktop"
[ -f "$dest" ] && cp -n "$dest" "$dest.bak"
install -Dm644 "$dir/chatgpt.desktop" "$dest"
kbuildsycoca6 >/dev/null 2>&1 || true
echo "Instalado: $dest"
