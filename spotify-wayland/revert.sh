#!/bin/sh
# Remove o atalho local; o Spotify volta a usar o atalho do snap (XWayland).
set -e
rm -f "$HOME/.local/share/applications/spotify_spotify.desktop"
kbuildsycoca6 >/dev/null 2>&1 || true
echo "Revertido."
