#!/bin/sh
# Instala o layout "Compacto com fechar" do Alt+Tab e o ativa: a lista leve do
# Compacto, com botão de fechar e a tecla Delete para fechar a janela selecionada.
set -e
dir=$(dirname "$(readlink -f "$0")")
dest="$HOME/.local/share/kwin-wayland/tabbox/compact_close"
rm -rf "$dest"
mkdir -p "$dest"
cp -r "$dir/compact_close/." "$dest/"
kwriteconfig6 --file kwinrc --group TabBox --key LayoutName compact_close
dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure
echo "Ativado. Alt+Tab agora usa o layout Compacto com fechar."
