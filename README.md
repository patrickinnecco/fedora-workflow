# linux-changes

Ajustes locais no Fedora 44 KDE Plasma 6.7.5 (Wayland, NVIDIA RTX 5070), com dois monitores:
um 2560×1440 de 27″ a **125%** (DP-2) e um 1920×1080 a **100%** (DP-1).

## 1. `display-scale/` — escala 125%/100% sem vão entre monitores

Depois de um teste com os dois monitores a 100%, o DP-1 ficou em `x=2560`. Com o DP-2 de volta a 125%,
a largura lógica dele passa a 2048, deixando um vão de 512 px entre as telas.

`apply.sh` define DP-2 = 1.25, DP-1 = 1.0 e posiciona o DP-1 em `2048,72` (bordas inferiores alinhadas:
1152 − 1080 = 72). O KWin passa a usar `[Xwayland] Scale=1.25` (Xft.dpi 120) automaticamente.

Reverter: `display-scale/revert.sh` (volta ao teste com ambos a 100%).

## 2. `chatgpt-wayland/` — ChatGPT em Wayland nativo

**Problema:** maximizado no monitor 2, o ChatGPT deixava 1 px à direita e 1 px embaixo mostrando o que estava atrás.
O KWin oferecia 1920×1080 (Dolphin e Opera ocupam exatamente isso), mas o ChatGPT enviava 1919×1079.

**Causa:** o app (Electron/Chromium 155) roda por padrão no **XWayland**. Com escala de XWayland 1,25, o KWin
converte coordenadas X fracionárias; 2399 ÷ 1,25 = 1919,2 → 1919. Além disso, no monitor a 100% um app X11
é desenhado em 1,25× e reduzido a 0,8× pelo compositor, o que o deixa borrado.

**Mudança:** o atalho local passa a abrir o app em Wayland nativo, mantendo o fcitx:

```
chatgpt --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3
```

Testado com uma instância separada: 20/20 trocas de monitor com a janela maximizada ocuparam a área exata
(1920×1080 no DP-1, 2048×1102 no DP-2). Ressalva: logo após abrir o app, o Chromium às vezes mantém o tamanho
antigo ao trocar de monitor; re-maximizar resolve.

Aplicar: `chatgpt-wayland/apply.sh` e reiniciar o ChatGPT. Reverter: `chatgpt-wayland/revert.sh`.
A diferença está em `chatgpt-wayland/chatgpt.desktop.diff`.

## Limitação conhecida (sem correção local)

Apps Qt/Wayland (Dolphin etc.) perdem um pouco de nitidez no monitor a 100% sempre que outra tela está
com escala ≠ 100%: o Qt 6.11.2 desliga o hinting das fontes com base no maior DPR da aplicação
(`qfontconfigdatabase.cpp`, `isDprScaling()`). Ver [QTBUG-129731](https://qt-project.atlassian.net/browse/QTBUG-129731)
(aberto) e [KDE bug 491015](https://bugs.kde.org/show_bug.cgi?id=491015).
