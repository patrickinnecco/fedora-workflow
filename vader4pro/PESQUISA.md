# Flydigi Vader 4 Pro no Linux — pesquisa

Fedora 44, KDE Plasma 6.7.5 (Wayland), kernel 7.2.11, SDL3 3.4.18, Wine 11.0, Steam (RPM) com `steam-devices`.
Data: 24/10/2026. **Somente análise:** nada foi instalado, criado (fora este arquivo) ou commitado.

Legenda de confiança: **[verificado]** = lido no sistema ou no código-fonte; **[relatado]** = issue, fórum ou
relato de usuário, ainda não testado aqui; **[a confirmar]** = dedução minha, que precisa de teste.

---

## 0. Estado atual do sistema (leitura feita agora)

| Item | Resultado |
|---|---|
| Controle conectado? | **Sim.** `Bus 001 Device 006: ID 045e:028e Microsoft Corp. Xbox360 Controller`, `Manufacturer=Flydigi`, `Product=Flydigi VADER4` **[verificado]** |
| Modo atual | **XInput** (VID:PID do Xbox 360, interface de classe vendor `ff/5d/01`) |
| Cabo ou dongle? | Não dá para saber pelo USB: os dois anunciam o mesmo ID. É full-speed (12 Mb/s), 500 mA, na porta 10.4 do hub ASMedia, e não existe `power_supply` de bateria. Olhe no próprio aparelho. |
| Driver | `xpad` (`usbcore: registered new interface driver xpad`), nome evdev `Microsoft X-Box 360 pad` |
| Nós | `/dev/input/event24` e `/dev/input/js0` (`by-id/usb-Flydigi_Flydigi_VADER4_Flydigi_VADER4-event-joystick`) |
| Botões expostos | `KEY=7cdb000000000000`, ou seja, o layout padrão do 360: A, B, X, Y, LB, RB, Back, Start, Guide, L3, R3. `ABS=3003f`: 2 sticks, 2 gatilhos e o D-pad como hat. **Nenhum** botão extra nem sensor |
| Permissões | O usuário **não** está no grupo `input`, mas tem ACL `rw` (uaccess do logind) em `/dev/uinput` e em `event24`. Um app comum já consegue **ler o pad e criar um pad virtual sem sudo** **[verificado]** |
| Regras udev | `/usr/lib/udev/rules.d/60-steam-input.rules` já dá uaccess a `hidraw*` com VID `04b4` ("Flydigi 2.4 GHz / Wired") e `37d7` ("Flydigi HIDAPI Enhanced Mode"), além de `/dev/uinput` |
| SDL3 do sistema | `libSDL3.so` 3.4.18 traz o driver `SDL_JOYSTICK_HIDAPI_FLYDIGI`, com a string "Flydigi Vader 4 Pro" **[verificado]** |
| Remapeadores instalados | Nenhum (`inputplumber`, `input-remapper`, `antimicrox`, `evsieve`, `keyd`, `sc-controller`, `hhd`, `makima`, `evtest`: ausentes) |
| Disponíveis nos repositórios Fedora 44 | `antimicrox` 3.6.0, `input-remapper` 2.2.1, `evtest`, `python3-evdev`, `kf6-kstatusnotifieritem` 6.31. **Não** estão nos repositórios: `inputplumber`, `evsieve`, `keyd`, `sc-controller`, `xboxdrv`, `hhd`, `makima` (seria preciso COPR ou build) |

---

## 1. Como o Vader 4 Pro funciona hoje no Linux

### 1.1 Modos e VID:PID

O modo muda por combinação de botões ao ligar ou pelo app da Flydigi (Space Station, só para Windows/Android).

| Modo | Conexão | VID:PID | Driver no kernel | Fonte |
|---|---|---|---|---|
| **XInput** | cabo e dongle 2.4 GHz | `045e:028e`, string de produto `Flydigi VADER4` | `xpad` | **[verificado]** neste PC |
| **DInput / modo Flydigi** (protocolo próprio) | cabo e dongle 2.4 GHz | `04b4:2412` (VID Cypress, que a Flydigi usa). O protocolo próprio fica na **interface HID 2**, usage page vendor `0xFFA0` | `hid-generic` (vários nós evdev genéricos) + leitura do protocolo por **hidraw** no userspace | **[verificado]** no código do SDL (`usb_ids.h`, `SDL_hidapi_flydigi.c`) e no InputPlumber. Na [issue Steam #12103](https://github.com/ValveSoftware/steam-for-linux/issues/12103) um usuário cita `04b4:2414`: pode variar por firmware ou revisão **[relatado]** |
| **Switch** | Bluetooth (e, pelos relatos, só este modo no BT) | emula o Switch Pro Controller (`057e:2009`) **[a confirmar]** | `hid-nintendo` | [Fórum Steam](https://steamcommunity.com/discussions/forum/10/595137684887870691/?l=english): funciona com giroscópio, mas sem os botões traseiros **[relatado]** |
| VID novo `37d7` ("HIDAPI Enhanced Mode") | — | `37d7:2401` (Vader 5 Pro), `37d7:2501` (Apex 5), `37d7:2502` (Apex 6) | `xpad` (o kernel tem `XPAD_XBOX360_VENDOR(0x37d7)`) + SDL hidraw | Vale para as linhas **mais novas**, não para o Vader 4 Pro. Fica como referência caso você troque de controle |

### 1.2 O que funciona e o que não funciona

| Recurso | XInput (`xpad`) | DInput/Flydigi (`04b4:2412`) | Switch BT (`hid-nintendo`) |
|---|---|---|---|
| Botões padrão, sticks, gatilhos analógicos | ✅ | ✅ (evdev genérico com mapeamento estranho; via SDL/Steam fica correto) | ✅ |
| 4 botões traseiros (M1–M4) | ❌ no kernel mainline: só funcionam se o firmware os mapear para botões padrão (perfil do Space Station) | ✅ via SDL3 HIDAPI (`SDL_GAMEPAD_BUTTON_FLYDIGI_M1..M4`), Steam Input (beta de jun/2025 em diante) e InputPlumber | ❌ **[relatado]** |
| C, Z e botão "círculo" | ❌ | Steam Input: parcial (em alguns betas aparecem rotulados como M1/M2). InputPlumber: C/Z viram toque no touchpad esquerdo/direito do pad virtual Deck | ❌ |
| Giroscópio/acelerômetro | ❌ (só existe a emulação de mouse do firmware, se ativada) | ✅ SDL3 3.4: sensores a ~1000 Hz no dongle e ~500 Hz no cabo (constantes `SENSOR_INTERVAL_VADER4_PRO_*`). Steam: relatos mistos (crash ao abrir a tela de giroscópio no Deck) | ✅ via `hid-nintendo` **[relatado]** |
| Vibração | ✅ (`ff_memless`) | ✅ no dongle e falha no cabo, segundo a [issue SDL #13208](https://github.com/libsdl-org/SDL/issues/13208). Vibração nos gatilhos: ❌ | ✅ HD rumble emulado |
| Dongle 2.4 GHz | ✅ | ✅ (o InputPlumber funciona com dongle e cabo) | n/a |
| Bluetooth | n/a | ❌ não é detectado em DInput via BT (issue Steam #12103, ago/2025) | ✅ |

**Patch do xpad para os botões extras:** o [PR paroj/xpad #268](https://github.com/paroj/xpad/pull/268) (aberto desde jan/2024) e o
[patch enviado à LKML](https://lkml.rescloud.iu.edu/2410.2/07949.html) por matoro (out/2024; rebase para 6.14 em jun/2025) reconhecem
`045e:028e` + string "Flydigi VADER3/VADER4". Eles adicionam C, Z e o círculo (`BTN_TRIGGER_HAPPY9..11`) e as paletas M1–M4
(`BTN_TRIGGER_HAPPY5..8`). **Não há sinal de que tenha sido aceito**: o PR segue aberto, o trecho lido do `xpad.c` mainline só cita a Flydigi
pelo VID `37d7` (Apex 5), e o kernel 7.2.11 daqui expõe só o layout padrão do 360 (a página do GitHub veio truncada, então isso não foi
conferido linha a linha).
Requisito relatado: limpar os mapeamentos do Space Station, senão os botões extras disparam em dobro (ex.: C também manda L3).

**Conclusão da seção:** no Linux, o modo que expõe **tudo** (paletas e giroscópio) é o **DInput/Flydigi (`04b4:2412`) por
cabo ou dongle**, lido via **hidraw** (SDL3, Steam ou InputPlumber). O modo XInput é o mais "compatível" com jogos, mas perde os
extras. O Bluetooth só serve no modo Switch e perde as paletas.

---

## 2. Projetos reaproveitáveis

Dados do GitHub consultados em 24/10/2026 (licença, linguagem, último push).

### 2.1 Específicos do Vader / Flydigi

| Projeto | Licença | Estado | O que resolve |
|---|---|---|---|
| [ShadowBlip/InputPlumber](https://github.com/ShadowBlip/InputPlumber) — driver `src/drivers/flydigi_vader_4_pro/`, config `devices/60-flydigi_vader_4_pro.yaml` | GPL-3.0+, Rust | **Muito ativo** (v0.83.0 em 21/10/2026, push hoje, 603★) | **O melhor ponto de partida.** Lê o hidraw `04b4:2412` na interface 02 (relatório 0x04, 32 bytes) e **bloqueia** os nós evdev duplicados. Expõe pad virtual (alvos: `xpad`, `deck`, `dualsense`, `unified_gamepad`, teclado, mouse, touchpad). Tem API D-Bus (`LoadProfilePath`, `InterceptMode`) e perfis YAML. Atenção: a config da Flydigi vem com `auto_manage: false` |
| [SDL3 — `SDL_hidapi_flydigi.c`](https://github.com/libsdl-org/SDL/blob/main/src/joystick/hidapi/SDL_hidapi_flydigi.c) | zlib | Ativo (3.4 já no Fedora) | Driver userspace completo: identifica o modelo pelo ID do firmware (85/91/105 = Vader 4 Pro), lê M1–M4, giroscópio e acelerômetro, e informa se a conexão é por fio ou sem fio. Todo jogo/emulador SDL3 (e Steam) ganha suporte "de graça" |
| [SDL issue #13208](https://github.com/libsdl-org/SDL/issues/13208) | — | Fechada (ago/2025) | Histórico de giroscópio e vibração dos Flydigi e das limitações (vibração por cabo, gatilhos) |
| [paroj/xpad PR #268](https://github.com/paroj/xpad/pull/268) + [patch LKML](https://lkml.rescloud.iu.edu/2410.2/07949.html) | GPL-2.0 (kernel) | Não aceito | C/Z/círculo/paletas no modo XInput. Exigiria compilar um módulo DKMS fora da árvore: não recomendo |
| [zeptic99/flydigiv4pro-linux](https://github.com/zeptic99/flydigiv4pro-linux) | MIT (segundo o README), Python | Pequeno (6★, 10 commits, último push em 01/2026) | DInput evdev → XInput virtual via uinput; giroscópio só pelo mouse do firmware. Serve de referência, não de base |
| [ValveSoftware/steam-devices](https://github.com/ValveSoftware/steam-devices) | MIT | Ativo | Regras udev de hidraw `04b4`/`37d7` que **já estão instaladas aqui** |
| [steam-for-linux #12103](https://github.com/ValveSoftware/steam-for-linux/issues/12103) | — | Aberta | Estado do Steam Input com o Vader 4 Pro (BT não funciona, C/Z instáveis) |

Não encontrei um "hid-flydigi" no kernel nem outros daemons "vader4" sérios no GitHub.

### 2.2 Remapeadores genéricos

| Projeto | Licença / linguagem | Estado | Serve para quê aqui |
|---|---|---|---|
| [InputPlumber](https://github.com/ShadowBlip/InputPlumber) | GPL-3.0, Rust | Ativo | Ver acima. Roda como serviço **root** (systemd), com polkit no D-Bus. Não está no Fedora (precisa de COPR ou RPM do projeto) |
| [Steam Input](https://store.steampowered.com) | proprietário | Ativo | Funciona para jogos lançados pelo Steam (incluindo "jogo não-Steam"). Paletas OK em DInput; C/Z e giroscópio instáveis. Faz XInput, teclado e mouse por jogo. **Conflita** com qualquer outro remapeador que também leia o hidraw |
| [SDL_GameControllerDB](https://github.com/mdqinc/SDL_GameControllerDB) | zlib | Ativo | Mapeamentos de joystick genérico. Para o Vader, o driver HIDAPI do SDL já cuida disso |
| [input-remapper](https://github.com/sezanzeb/input-remapper) | GPL-3.0, Python | Ativo (2.2.1 no Fedora) | Remapeia evdev → teclado, mouse ou gamepad com presets por dispositivo. Não lê hidraw, então em XInput não vê as paletas. Tem GUI e daemon root |
| [AntiMicroX](https://github.com/AntiMicroX/antimicrox) | GPL-3.0, C++/Qt | Ativo (3.6.0 no Fedora) | Pad → teclado e mouse via SDL, com perfis e troca automática por janela (só funciona em X11; no Wayland é limitada). Como usa SDL3, vê as paletas e o giroscópio. Boa referência de UI |
| [evsieve](https://github.com/KarsMulder/evsieve) | GPL-2.0, Rust | Ativo | Linha de comando: evdev → uinput com `--grab`. Ótimo para protótipo rápido |
| [keyd](https://github.com/rvaiya/keyd) | MIT, C | Ativo | Focado em teclado. Pouco útil para pad |
| [makima](https://github.com/cyber-sushi/makima) | GPL-3.0, Rust | Ativo, mas lento (último push em 01/2026) | Pad → teclado e mouse com **perfis por janela ativa**, inclusive no KDE Wayland via script KWin. Boa referência para a troca de perfil |
| [sc-controller (fork C0rn3j)](https://github.com/C0rn3j/sc-controller) | GPL-2.0, Python | Ativo | Mapeamentos ricos estilo Steam Input para vários pads (evdev). Interface GTK |
| [Handheld Daemon (hhd)](https://github.com/hhd-dev/hhd) | LGPL-2.1, Python | Ativo | Foco em portáteis (Ally, Legion). Arquitetura parecida (hidraw → uinput) |
| [xboxdrv](https://github.com/xboxdrv/xboxdrv) | GPL-3.0, C++ | Revivido (push em 08/2026) | Legado. Não recomendo |

### 2.3 Camadas de compatibilidade para jogos antigos (Wine/Proton e emuladores)

**Como o Wine vê o controle** (Wine 11): o `winebus.sys` tem três backends: **SDL** (padrão), **evdev/udev** e **hidraw**
(só para dispositivos "conhecidos"). Todo pad que o SDL reconhece como gamepad vira **XInput e DInput ao mesmo tempo**.
Jogos antigos às vezes pegam o dispositivo errado ou o duplicado (relatos nos bugs do Wine, ver abaixo).
Ajustes ficam em `HKLM\System\CurrentControlSet\Services\WineBus`: `Enable SDL` (DWORD 0/1), `DisableHidraw`, `DisableInput`.
Também dá para desativar um dispositivo pelo `wine control joy.cpl`
([discussão nos bugs 57023/56306](https://list.winehq.org/hyperkitty/list/wine-bugs@list.winehq.org/thread/KV5LTARAN64FV3RF54QP4YOA3IGCWQ4A/)).
**Consequência para o app:** o ideal é que o jogo enxergue **um único** pad: o virtual.

**Wrappers dentro do prefixo:**
- [Xidi](https://github.com/samuelgr/Xidi) (BSD-3-Clause, ativo): `dinput8.dll`/`dinput.dll`/`winmm.dll` que entrega ao jogo DInput um pad
  XInput bem mapeado, com mapeadores prontos (inclusive "SH4") e plugin SDL3. É a peça-chave para os Silent Hill de PC.
  Exige override `dinput8=n,b` no Wine.
- XInput Plus e x360ce: alternativas mais antigas e só para Windows. Funcionam no Wine, mas o Xidi é mais limpo.

**Resident Evil 1/2/3 (PC original de 1996–2000):**
- [Classic REbirth](https://classicrebirth.com/index.php/downloads/resident-evil-classic-rebirth/) (fechado, gratuito): o **RE1** troca o módulo
  antigo de joystick (WinMM) por **SDL3 Input + Steam Input**. O RE1 Classic REbirth é para a versão japonesa MediaKite.
  O [RE2 Classic REbirth](https://classicrebirth.com/index.php/downloads/resident-evil-2-classic-rebirth/) oferece **XInput, Raw Input e DirectInput**.
  Use XInput para o pad virtual 360 (gatilhos e D-pad corretos) e Raw Input para DualShock. O RE3 segue a mesma linha.
  O `config.ini` é criado na primeira execução **[relatado]**.
- No Proton, os guias usam `WINEDLLOVERRIDES="ddraw,dinput8,d3d9,dsound=n,b"` ([ProtonDB](https://www.protondb.com/app/4249110),
  [guia GBAtemp](https://gbatemp.net/threads/how-to-run-resident-evil-2-1998-gog-with-classic-rebirth-and-seamless-hd-project.660172/)).
  Ligue o controle **antes** de abrir o menu do REbirth.
- Com o Classic REbirth do RE1 usando SDL3 dentro do Wine, ele pode até ver o Vader "real" via hidraw, se o Wine expuser. O caminho
  previsível continua sendo o pad virtual XInput.

**Silent Hill:**
- **SH1:** só existe no PS1, então o caminho é emulador (DuckStation, Beetle PSX no RetroArch). Os emuladores usam SDL, então leem o
  Vader nativamente (o DuckStation tem "analog to D-pad", útil no SH1) **[a confirmar]**.
- **SH2 (PC):** [Silent Hill 2: Enhanced Edition](https://github.com/elishacloud/Silent-Hill-2-Enhancements) (zlib, muito ativo). A
  [página de troubleshooting](https://enhanced.townofsilenthill.com/SH2/troubleshoot.htm) recomenda um **controle XInput + Xidi**.
  O `dinput8.dll` do pacote **é o Xidi** e permite hot-swap. Ela também diz que o jogo **usa o primeiro controle conectado** e que é bom
  desconectar outros pads e dongles. Já houve um fix específico para Linux ("disable loading modules from memory"). Vibração em DInput
  não é garantida.
- **SH3 (PC):** só entende DInput. O [SH3 PC Fix (steam006)](https://community.pcgamingwiki.com/files/file/1331-silent-hill-3-pc-fix-by-steam006)
  resolve imagem e resolução, mas não o controle. Para o pad, use **Xidi** (`dinput8=n,b`) **[a confirmar no SH3]**.
- **SH4 (PC/GOG):** solução documentada no [GOG](https://www.gog.com/forum/silent_hill_4_the_room/fully_working_solution_for_xinput_controller_support):
  Xidi ≥4.0.3 (`dinput8.dll` Win32), `Xidi.ini` com o mapeador SH4 e o stick direito em RotX/RotY, `dinput8` e `d3d8` como `native, builtin`.
- **SH2/3/4 versões de PS2:** use PCSX2 (SDL3), que lê o Vader nativamente.

**GE-Proton:** a [11-4](https://www.gamingonlinux.com/2026/08/ge-proton-11-4-brings-lots-of-controller-improvements/) trouxe hidraw→XInput
**só para pads Sony** (`PROTON_SONY_HIDRAW_XINPUT=1`) e um fallback de Steam Input. Não há equivalente para a Flydigi, e um pad virtual
360 dispensa isso.

---

## 3. Arquitetura recomendada para o app da bandeja

### 3.1 Decisão: InputPlumber como motor, app próprio como front-end

Fase 1: **usar o InputPlumber como motor** (ele já tem o driver do Vader 4 Pro via hidraw, esconde os nós duplicados, cria pads
virtuais XInput/teclado/mouse e aceita perfis via D-Bus). O app da bandeja vira um **front-end**: escolhe o perfil, detecta o jogo e
mostra o estado. É o caminho com menos código e mais manutenção de terceiros.

Fase 2 (só se o InputPlumber limitar: por exemplo, mapeamento de giroscópio, latência ou não querer um serviço root): um daemon próprio
**no nível do usuário**, sem root, porque as ACLs uaccess já existem aqui:

```
Vader (modo DInput 04b4:2412, cabo/dongle)
   └─ hidraw (interface 2) ──► daemon: SDL3 Gamepad API (driver Flydigi: paletas + giroscópio)
   └─ evdev genéricos ─────► EVIOCGRAB (some para os jogos)
                                  │ perfil ativo (por jogo)
                                  ▼
             uinput: pad virtual Xbox 360 (045e:028e) | teclado virtual | mouse virtual (giroscópio)
                                  ▼
               Wine/Proton (XInput + DInput via winebus/Xidi) · emuladores · nativos
```

- **Pad virtual com ID 045e:028e:** o `xpad`, o SDL, o Wine e o Xidi tratam esse pad como "Xbox 360 de verdade". Isso dá máxima
  compatibilidade para jogos XInput e, via Xidi, para jogos DInput.
- **Esconder o físico:** EVIOCGRAB nos evdev + variável `SDL_GAMECONTROLLER_IGNORE_DEVICES=0x04b4/0x2412` no ambiente dos jogos
  (no Wine, o backend SDL também leria o hidraw). Por isso o físico deve ficar em **DInput** e o virtual em **045e:028e**: os IDs
  diferentes permitem ignorar só o físico.
- **Mapeamento para teclado** (jogos que só aceitam teclado): teclado virtual uinput com perfil por jogo (ex.: RE1 Classic REbirth
  sem pad).
- **Vibração:** o pad virtual precisa implementar FF no uinput (`UI_FF_UPLOAD`/`UI_FF_ERASE`) e repassar ao físico (SDL `SDL_RumbleGamepad`).
  É o pedaço mais trabalhoso.

### 3.2 Linguagem e toolkit

- **C++20 + Qt 6 / QML + KDE Frameworks 6**, coerente com o `linux-icondrawer` (fork C++/QML do Plasma) e com bibliotecas já no
  sistema: SDL3 3.4.18, `kf6-kstatusnotifieritem` 6.31.
- **Bandeja:** `KStatusNotifierItem` (SNI nativo; aparece no Icon Drawer como qualquer ícone). `QSystemTrayIcon` também usa SNI no Plasma,
  mas o KSNI dá menu, status (Active/Passive/NeedsAttention) e tooltip ricos.
- **Janela só ao clicar, fora da barra de tarefas:** `KStatusNotifierItem::setAssociatedWindow` abre e fecha a janela no clique. Para não
  aparecer na barra no Wayland, as opções são `Qt::Tool` (o KWin costuma pular janelas utilitárias) ou uma regra do KWin `skiptaskbar`
  instalada pelo app **[a confirmar no Plasma 6.7.5]**. Alternativa: só o menu e um popup QML.
- **Motor separado** (fase 2): processo próprio como serviço `systemd --user`, com a UI falando com ele por D-Bus. A UI pode fechar ou
  travar sem derrubar o input. Rust também é uma opção boa para o motor (o mesmo do InputPlumber, com crates `evdev` e `hidapi`), mas
  C++/SDL3 reaproveita o driver Flydigi pronto.

### 3.3 Permissões

| Recurso | Situação aqui | O que fazer (só descrito; se precisar de sudo, é você quem roda) |
|---|---|---|
| `/dev/uinput` | ACL uaccess já dá `rw` ao usuário (regra do steam-devices) | Nada |
| evdev do pad | uaccess (`ID_INPUT_JOYSTICK`) | Nada. Evitar o grupo `input`, que libera leitura do teclado (keylogger) |
| hidraw `04b4`/`37d7` | uaccess via `60-steam-input.rules` | Nada. Se o pacote steam-devices sair, uma regra própria em `/etc/udev/rules.d/` (sudo) |
| InputPlumber (fase 1) | — | Instalar o RPM/COPR, `systemctl enable --now inputplumber` e ativar o device Flydigi (`auto_manage: false` por padrão). Tudo com sudo |

### 3.4 Detectar o jogo em foco (Wayland/KWin)

O Wayland não dá ao app a "janela ativa". No Plasma, o caminho é um **script do KWin** (JavaScript) instalado pelo app que escuta
`workspace.windowActivated` e chama `callDBus(...)` no app com `resourceClass`, `caption` e `pid`. É a técnica do
[kdotool](https://docs.rs/kdotool/) e do [makima](https://github.com/cyber-sushi/makima).
Do `pid`, o app lê `/proc/<pid>/cmdline` e `environ` (`SteamAppId`, `WINEPREFIX`, nome do `.exe`) para identificar jogos Wine/Proton,
cuja classe costuma ser `steam_app_NNN` ou `jogo.exe`.
**Complemento mais confiável:** um wrapper de lançamento (`vader-run --profile sh2 %command%` nas opções de lançamento do Steam/Lutris/Heroic)
que avisa o motor qual perfil usar enquanto o processo viver. Esse wrapper também serve para injetar `SDL_GAMECONTROLLER_IGNORE_DEVICES`
e `WINEDLLOVERRIDES`.

---

## 4. Riscos, lacunas e próximos passos

### 4.1 Riscos e lacunas

1. **Duplicidade de controles.** Este é o problema nº 1 dos jogos antigos ("usa o primeiro controle"). Físico, virtual e Steam Input
   juntos produzem 2 ou 3 pads. É preciso grab + ignore do SDL + Steam Input desligado por jogo.
2. **Conflito com o Steam:** o Steam lê o hidraw `04b4` sozinho. Com o motor ativo, desligue o Steam Input para o jogo ou para a Flydigi.
3. **Firmware e IDs variam:** `2412` no SDL/InputPlumber e `2414` num relato. Os IDs de firmware do Vader 4 Pro são 85/91/105 no SDL.
   Atualizações do Space Station (só no Windows) podem mudar o protocolo.
4. **Bluetooth:** só o modo Switch, sem paletas. Não existe solução software conhecida; use o dongle.
5. **Perfis no firmware:** mapeamentos do Space Station ou a emulação de mouse por giroscópio ativa geram eventos duplicados ou fantasmas.
   Deixe o firmware "limpo".
6. **XInput no kernel:** o patch do xpad nunca entrou, então não conte com as paletas no modo XInput.
7. **InputPlumber:** não está no Fedora, roda como root e evolui rápido (pode quebrar a config entre versões). A config Flydigi
   vem com `auto_manage: false` e usa o alvo `deck` por padrão; para jogos Wine antigos o alvo `xpad` é melhor.
8. **Wayland:** depende da API de scripts do KWin, que mudou do Plasma 5 para o 6. Jogos em gamescope aninhado escondem a janela
   real, e nesse caso só o wrapper resolve.
9. **Vibração:** repassar FF do uinput ao pad é trabalhoso. A vibração por cabo em DInput está quebrada no próprio SDL.
10. **Itens não testados aqui:** o ID do modo Switch, a troca de modo e o comportamento real em cada jogo RE/SH com Wine 11.
    Tudo isso precisa de teste com o controle em mãos.

### 4.2 Próximos passos priorizados

1. **(Sem instalar nada)** Passar o controle para o modo **DInput** (cabo e depois dongle) e repetir a leitura deste relatório
   (`lsusb`, `/proc/bus/input/devices`, `ls /dev/hidraw*`). O objetivo é confirmar `04b4:2412` e quantos nós aparecem.
2. Testar o caminho "zero instalação": `SDL3` já vê paletas e giroscópio. Um emulador SDL3 (DuckStation ou PCSX2, se já estiverem
   instalados) ou `testcontroller` do SDL confirma isso.
3. **(Decisão)** Instalar o `evtest` (repositório Fedora, sudo) para inspecionar os eventos, e o InputPlumber via COPR/RPM oficial
   para testar o driver Flydigi com o alvo `xpad`.
4. Montar uma matriz de testes por jogo: RE2 Classic REbirth em modo XInput, SH2EE com Xidi, SH4 com Xidi + `Xidi.ini`, SH3 com Xidi.
   Primeiro com o Vader em XInput puro (que talvez já baste para esses jogos), depois com o pad virtual.
5. Protótipo do motor: InputPlumber + perfil YAML (fase 1) **ou** `evsieve --grab` para validar a ideia de pad virtual + teclado.
6. Protótipo da UI: Qt6/QML + `KStatusNotifierItem`, janela fora da barra de tarefas, conversa com o InputPlumber por D-Bus.
7. Script do KWin para a janela ativa + wrapper `vader-run` → troca automática de perfil.
8. Só então avaliar a fase 2 (motor próprio com SDL3 + uinput, vibração e giroscópio → mouse).

---

### Fontes principais
- Código: [SDL `SDL_hidapi_flydigi.c`](https://github.com/libsdl-org/SDL/blob/main/src/joystick/hidapi/SDL_hidapi_flydigi.c), [SDL `usb_ids.h`](https://github.com/libsdl-org/SDL/blob/main/src/joystick/usb_ids.h), [InputPlumber](https://github.com/ShadowBlip/InputPlumber) (`devices/60-flydigi_vader_4_pro.yaml`, `src/drivers/flydigi_vader_4_pro/`), [xpad.c mainline](https://github.com/torvalds/linux/blob/master/drivers/input/joystick/xpad.c)
- Issues/patches: [steam-for-linux #12103](https://github.com/ValveSoftware/steam-for-linux/issues/12103), [SDL #13208](https://github.com/libsdl-org/SDL/issues/13208), [paroj/xpad #268](https://github.com/paroj/xpad/pull/268), [patch LKML](https://lkml.rescloud.iu.edu/2410.2/07949.html), [fórum Steam (modo Switch)](https://steamcommunity.com/discussions/forum/10/595137684887870691/?l=english)
- Docs: [InputPlumber usage](https://inputplumber.readthedocs.io/en/latest/usage/), [kdotool](https://docs.rs/kdotool/), [Wine WineBus (bugs 57023/56306)](https://list.winehq.org/hyperkitty/list/wine-bugs@list.winehq.org/thread/KV5LTARAN64FV3RF54QP4YOA3IGCWQ4A/)
- Jogos: [Classic REbirth RE1](https://classicrebirth.com/index.php/downloads/resident-evil-classic-rebirth/), [RE2 Classic REbirth](https://classicrebirth.com/index.php/downloads/resident-evil-2-classic-rebirth/), [SH2EE troubleshooting](https://enhanced.townofsilenthill.com/SH2/troubleshoot.htm), [SH2 Enhancements](https://github.com/elishacloud/Silent-Hill-2-Enhancements), [SH4 + Xidi (GOG)](https://www.gog.com/forum/silent_hill_4_the_room/fully_working_solution_for_xinput_controller_support), [SH3 PC Fix](https://community.pcgamingwiki.com/files/file/1331-silent-hill-3-pc-fix-by-steam006), [Xidi](https://github.com/samuelgr/Xidi), [GE-Proton 11-4](https://www.gamingonlinux.com/2026/08/ge-proton-11-4-brings-lots-of-controller-improvements/)
