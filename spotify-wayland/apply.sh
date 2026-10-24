#!/bin/sh
# Instala um atalho local que abre o Spotify (snap) em Wayland nativo, com IME do fcitx.
# O atalho em ~/.local/share/applications tem precedência sobre o gerado pelo snap.
set -e
dir=$(dirname "$(readlink -f "$0")")
install -Dm644 "$dir/spotify_spotify.desktop" "$HOME/.local/share/applications/spotify_spotify.desktop"
kbuildsycoca6 >/dev/null 2>&1 || true
echo "Instalado. Reinicie o Spotify."
