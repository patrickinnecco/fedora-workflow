#!/bin/sh
# Snapshots do sistema (snapper + btrfs-assistant), MangoHud e Yakuake.
# Rode com: sudo sh apply.sh
set -eu
[ "$(id -u)" = 0 ] || { echo "Rode com sudo."; exit 1; }
user=${SUDO_USER:?Rode com sudo a partir do seu usuário.}
uuid=$(findmnt -no UUID /)

dnf install -y snapper btrfs-assistant libdnf5-plugin-actions mangohud.x86_64 mangohud.i686 yakuake

# Config "root" para o subvolume do sistema (/home fica de fora).
snapper -c root get-config >/dev/null 2>&1 || snapper -c root create-config /

# Snapshots num subvolume próprio no topo do btrfs (layout plano), montado em /.snapshots.
# Assim, voltar o sistema para um snapshot não apaga os outros snapshots.
if ! findmnt -n /.snapshots >/dev/null; then
    btrfs subvolume delete /.snapshots
    top=$(mktemp -d)
    mount -o subvolid=5 "UUID=$uuid" "$top"
    [ -e "$top/snapshots" ] || btrfs subvolume create "$top/snapshots"
    umount "$top"
    rmdir "$top"
    mkdir /.snapshots
    if ! grep -q '[[:space:]]/\.snapshots[[:space:]]' /etc/fstab; then
        cp /etc/fstab /etc/fstab.antes-snapper
        echo "UUID=$uuid /.snapshots btrfs subvol=snapshots,compress=zstd:1 0 0" >> /etc/fstab
    fi
    systemctl daemon-reload
    mount /.snapshots
    chown root:root /.snapshots
    chmod 750 /.snapshots
    restorecon -R /.snapshots
fi

# Só snapshots de atualização (antes/depois de cada dnf), sem snapshots por hora.
snapper -c root set-config TIMELINE_CREATE=no NUMBER_LIMIT=20 NUMBER_LIMIT_IMPORTANT=5 \
    ALLOW_USERS="$user" SYNC_ACL=yes
systemctl disable --now snapper-timeline.timer 2>/dev/null || true
systemctl enable --now snapper-cleanup.timer

# Snapshot antes/depois de cada transação do dnf (exemplo oficial do plugin actions do dnf5, com limpeza "number").
cat > /etc/dnf/libdnf5-plugins/actions.d/snapper.actions <<'EOF'
# Cria a descrição do snapshot e guarda em "tmp.snapper_descr".
pre_transaction::::/usr/bin/sh -c echo\ "tmp.snapper_descr=$(ps\ -o\ command\ --no-headers\ -p\ '${pid}')"

# Cria o snapshot "pre" antes da transação e guarda o número em "tmp.snapper_pre_number".
pre_transaction::::/usr/bin/sh -c echo\ "tmp.snapper_pre_number=$(snapper\ create\ -t\ pre\ -c\ number\ -p\ -d\ '${tmp.snapper_descr}')"

# Se existe "tmp.snapper_pre_number", cria o snapshot "post" e remove as variáveis.
post_transaction::::/usr/bin/sh -c [\ -n\ "${tmp.snapper_pre_number}"\ ]\ &&\ snapper\ create\ -t\ post\ -c\ number\ --pre-number\ "${tmp.snapper_pre_number}"\ -d\ "${tmp.snapper_descr}"\ ;\ echo\ tmp.snapper_pre_number\ ;\ echo\ tmp.snapper_descr
EOF

snapper -c root list | grep -q 'Base: sistema configurado' ||
    snapper -c root create -d "Base: sistema configurado" --userdata important=yes

echo
snapper -c root list
echo
echo "Pronto. Snapshots em /.snapshots; abra o Btrfs Assistant para ver ou restaurar."
