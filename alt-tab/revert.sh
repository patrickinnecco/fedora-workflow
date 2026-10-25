#!/bin/sh
# Volta ao layout Compacto nativo (sem fechar) e remove o layout instalado.
set -e
kwriteconfig6 --file kwinrc --group TabBox --key LayoutName compact
dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure
rm -rf "$HOME/.local/share/kwin-wayland/tabbox/compact_close"
echo "Revertido. Alt+Tab voltou ao layout Compacto."
