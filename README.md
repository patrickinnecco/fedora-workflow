# fedora-workflow

Ajustes e widgets do meu Fedora 44 KDE Plasma 6.7.5 (Wayland, NVIDIA RTX 5070), com dois monitores:
um 2560×1440 de 27″ a **125%** (DP-2) e um 1920×1080 a **100%** (DP-1).

| Pasta | O que é |
|---|---|
| [`display-scale/`](display-scale/) | Escala 125%/100% sem vão entre os monitores |
| [`alt-tab/`](alt-tab/) | Alt+Tab compacto e rápido, com botão de fechar e tecla Delete |
| [`extras/`](extras/) | Snapshots do sistema antes de cada atualização, MangoHud, ProtonPlus e Yakuake |
| `*-wayland/` | Apps Electron/Chromium em Wayland nativo, nítidos nos dois monitores |
| [`linux-icondrawer/`](linux-icondrawer/) | Icon Drawer: bandeja do sistema com gaveta estilo Windows (fork da System Tray do Plasma 6.7.5) — ver o [README](linux-icondrawer/README.md) |
| [`linux-showdesktop/`](linux-showdesktop/) | Scadutree Show Desktop: botão de mostrar a área de trabalho no canto do painel — ver o [README](linux-showdesktop/README.md) |

`linux-icondrawer/` e `linux-showdesktop/` vieram dos repositórios de mesmo nome, com o histórico de commits
preservado. Os comandos de build e instalação nos READMEs deles devem ser executados dentro da respectiva pasta.

## 1. `display-scale/` — escala 125%/100% sem vão entre monitores

Depois de um teste com os dois monitores a 100%, o DP-1 ficou em `x=2560`. Com o DP-2 de volta a 125%,
a largura lógica dele passa a 2048, deixando um vão de 512 px entre as telas.

`apply.sh` define DP-2 = 1.25, DP-1 = 1.0 e posiciona o DP-1 em `2048,72` (bordas inferiores alinhadas:
1152 − 1080 = 72). O KWin passa a usar `[Xwayland] Scale=1.25` (Xft.dpi 120) automaticamente.

Reverter: `display-scale/revert.sh` (volta ao teste com ambos a 100%).

## 2. `*-wayland/` — apps Electron/Chromium em Wayland nativo

**Problema:** apps baseados em Electron ou Chromium (incluindo CEF) abrem por padrão no **XWayland**. Em escala
mista isso causa dois defeitos:

- **Borrão no monitor a 100%:** o XWayland usa uma única escala para todas as telas (aqui 1,25). No monitor a
  100%, o app desenha em 1,25× e o compositor reduz a imagem para 0,8×.
- **Faixa na janela maximizada:** o KWin converte coordenadas X fracionárias, e o arredondamento pode deixar a
  janela 1 px menor que a área (2399 ÷ 1,25 = 1919,2 → 1919), mostrando o que está atrás na borda.

**Mudança:** cada pasta `*-wayland/` contém um atalho `.desktop` local, que tem precedência sobre o do sistema
ou do snap e passa a abrir o app em Wayland nativo, mantendo o IME do fcitx:

```
--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland \
--enable-wayland-ime --wayland-text-input-version=3
```

Os apps mais novos só precisam de `--ozone-platform=wayland`; os demais também precisam de `UseOzonePlatform`.
Cada pasta traz o atalho original, o diff e os scripts `apply.sh` / `revert.sh`. Depois de aplicar, reinicie o app.

**Testado:** os apps abrem sem nenhuma janela X11 e, maximizados, ocupam a área exata nos dois monitores
(2048×1102 no DP-2, 1920×1080 no DP-1), inclusive em 20 trocas seguidas de monitor. Ressalva: logo após abrir
um app, o Chromium às vezes mantém o tamanho antigo ao trocar de monitor; re-maximizar resolve.

Apps que já rodam em Wayland nativo (Flatpaks só com acesso a Wayland, apps GTK3/Flutter e navegadores já
configurados) não precisam de mudança. Apps sem modo Wayland continuam no XWayland: nítidos no 1440p e
borrados no 1080p.

## 3. `alt-tab/` — Alt+Tab compacto com fechar

**Antes:** para deixar o Alt+Tab mais rápido, o seletor passou a usar o layout *Compacto* (lista de texto,
sem miniaturas), sem atraso (`DelayTime=0`) e sem destacar as janelas. O Compacto do KWin não tem como fechar
janelas; só o layout de miniaturas tem o botão de fechar.

**Mudança:** `compact_close/` é o Compacto do KWin 6.7.5 com duas adições: um botão ✕ na linha selecionada ou
sob o mouse e a tecla **Delete**, que fecha a janela selecionada sem soltar o Alt. O resto é igual, então o
seletor continua leve. `apply.sh` instala o layout em `~/.local/share/kwin-wayland/tabbox/` e o ativa; o
efeito é imediato.

Reverter: `alt-tab/revert.sh` (volta ao Compacto nativo).

**Testado** numa sessão KWin aninhada: Alt+Tab, Delete fecha a janela selecionada e a lista continua aberta;
clicar no ✕ também fecha; ao soltar o Alt, a janela selecionada é ativada.

## 4. `extras/` — snapshots, MangoHud, ProtonPlus e Yakuake

`sudo sh extras/apply.sh` instala e configura:

- **Snapshots do sistema** (snapper + Btrfs Assistant), como os pontos de restauração do Windows. Antes e
  depois de cada `dnf install/upgrade/remove`, o snapper tira um snapshot do subvolume do sistema (`root`). O
  `/home` fica de fora: voltar o sistema não mexe nos seus arquivos. Ficam os 20 snapshots mais recentes, mais
  um snapshot "Base" marcado como importante. Não há snapshots por hora.
  - Os snapshots ficam no subvolume `snapshots`, no topo do btrfs, montado em `/.snapshots` (linha nova no
    `/etc/fstab`; o original fica em `/etc/fstab.antes-snapper`). Assim, restaurar o sistema não apaga os
    outros snapshots.
  - O gancho do dnf está em `/etc/dnf/libdnf5-plugins/actions.d/snapper.actions` (exemplo oficial do plugin
    `actions` do dnf5).
  - Ver a lista: `snapper -c root list`, sem sudo.
  - **Restaurar:** abra o *Btrfs Assistant*, aba *Snapper*, *Browse/Restore*, escolha o snapshot "pre" da
    atualização que deu problema e clique em *Restore*. Depois, reinicie.
  - O `/boot` é ext4 e não entra no snapshot. Se voltar para antes de uma atualização de kernel, escolha no
    GRUB o kernel anterior, porque o mais novo perde os módulos.
  - Não dá para iniciar um snapshot pelo GRUB. Se o sistema não iniciar nem com o kernel anterior, restaure
    por um pendrive do Fedora.
- **MangoHud** (64 e 32 bits): FPS, tempos de quadro, CPU e GPU sobre o jogo. Na Steam, use a opção de
  inicialização `mangohud %command%`. **Shift direito + F12** mostra ou esconde o overlay.
- **Yakuake:** terminal que desce do topo da tela com **F12**. Para iniciar com a sessão (sem sudo):
  `cp /usr/share/applications/org.kde.yakuake.desktop ~/.config/autostart/`.

O **ProtonPlus** é instalado sem sudo, como Flatpak do usuário (`flatpak install --user flathub
com.vysp3r.ProtonPlus`). Ele baixa versões do Proton-GE para a Steam; depois de instalar uma versão,
reinicie a Steam e escolha a versão em *Propriedades do jogo > Compatibilidade*.

Reverter:

- `sudo snapper -c root delete-config` e `sudo rm /etc/dnf/libdnf5-plugins/actions.d/snapper.actions`;
  depois, tire a linha `/.snapshots` do `/etc/fstab`.
- `sudo dnf remove snapper btrfs-assistant mangohud yakuake`
- `flatpak uninstall --user com.vysp3r.ProtonPlus`

## Limitação conhecida (sem correção local)

Apps Qt/Wayland perdem um pouco de nitidez no monitor a 100% sempre que outra tela está
com escala ≠ 100%: o Qt 6.11.2 desliga o hinting das fontes com base no maior DPR da aplicação
(`qfontconfigdatabase.cpp`, `isDprScaling()`). Ver [QTBUG-129731](https://qt-project.atlassian.net/browse/QTBUG-129731)
(aberto) e [KDE bug 491015](https://bugs.kde.org/show_bug.cgi?id=491015).
