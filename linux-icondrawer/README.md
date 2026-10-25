# linux-icondrawer

**Icon Drawer** (Gaveta de Ícones) é uma bandeja do sistema para o KDE Plasma 6
com uma gaveta no estilo do Windows: os ícones podem ser arrastados entre o
painel e a gaveta da seta ^.

É um fork da System Tray do Plasma 6.7.5 (`plasma-workspace/applets/systemtray`).
Tudo o que a bandeja nativa faz continua igual: ícones de aplicativos
(StatusNotifierItem), applets como Volume, Rede e Notificações, menus de
contexto, atalhos e a página de configuração.

## O que muda em relação à bandeja nativa

- **Arrastar para a gaveta:** arraste um ícone do painel até a seta ^ ou até a
  gaveta aberta. Se o ícone ficar parado sobre a seta, a gaveta se abre
  sozinha.
- **Arrastar para o painel:** arraste um ícone da gaveta até os ícones do
  painel. Durante o arrasto, o painel reserva um espaço vazio para soltar,
  mesmo quando todos os ícones estão na gaveta.
- **Organizar a gaveta:** o botão *Organize Drawer*, no cabeçalho da gaveta,
  lista os ícones ativos, cada um com três opções: *Panel* (sempre no
  painel), *Drawer* (só na gaveta) e *Auto* (o app decide).
- **Mostrar só os apps:** o botão de filtro *Show Only Apps*, no cabeçalho da
  gaveta, esconde dela os itens do sistema e deixa só os apps instalados.
  Clique de novo para ver os itens do sistema. A escolha fica gravada e vale
  depois de reiniciar. A mesma opção está na página de configuração, em
  *Drawer: Show only apps (hide system items)*. São considerados do sistema:
  - os widgets da bandeja (Volume, Rede, Notificações, Discos etc.);
  - os ícones de categoria *SystemServices* ou *Hardware*, como o do método
    de entrada (Fcitx);
  - componentes do sistema que aparecem como ícones comuns: a
    *Xwayland Video Bridge* e o aviso de atualizações do Discover.

  Os itens escondidos continuam carregados e continuam listados no
  *Organize Drawer*, de onde podem voltar para o painel. Itens do sistema que
  estão no painel não mudam.
- **Ícones de apps em uma cor:** a opção *App icons: Single color, like the
  system icons*, na página de configuração, desenha os ícones dos apps como
  glifos de uma cor só, na cor do texto do tema, como os ícones do sistema.
  Cada ícone é separado em dois tons (limiar de Otsu sobre a luminância): o
  tom de maior área vira o glifo e o outro é vazado, o que preserva detalhes
  como o ▶ do Spotifast ou o "qb" do qBittorrent. Ícones de um tom só viram
  silhueta. Vale para o painel e para a gaveta e acompanha a troca de tema.

O arrasto e o gerenciador gravam apenas as mesmas chaves que a configuração
nativa usa (`shownItems` e `hiddenItems`). Nenhum item é habilitado ou
desabilitado por eles. Um ícone guardado continua funcionando e aparece ao
abrir a gaveta. Para desabilitar um item, use a página de configuração da
bandeja, como na versão nativa.

Um clique simples continua abrindo o item. O arrasto só começa depois que o
mouse se move com o botão pressionado.

## Compilação

O plugin é C++ e depende da versão do Plasma em que foi compilado. Ele foi
escrito e testado com o Plasma 6.7.5, Qt 6.11 e KDE Frameworks 6.31 do
Fedora 44.

Dependências no Fedora:

```
sudo dnf install cmake extra-cmake-modules gcc-c++ ninja-build \
    qt6-qtbase-devel qt6-qtbase-private-devel qt6-qtdeclarative-devel \
    libplasma-devel kf6-kconfig-devel kf6-kiconthemes-devel kf6-ki18n-devel \
    kf6-kio-devel kf6-kjobwidgets-devel kf6-kservice-devel \
    kf6-kitemmodels-devel kf6-kwindowsystem-devel kf6-kxmlgui-devel \
    kf6-kstatusnotifieritem-devel
```

Compilar e instalar:

```
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
sudo cmake --install build
```

Os arquivos instalados ficam listados em `build/install_manifest.txt`:

- `/usr/lib64/qt6/plugins/plasma/applets/com.scadutree.icondrawer.so`
- `/usr/lib64/qt6/qml/com/scadutree/icondrawer/private/`

Depois de uma atualização do Plasma, recompile e reinstale o plugin.

## Uso no painel

O plugin tem ID próprio (`com.scadutree.icondrawer`) e não substitui nem
altera a bandeja nativa.

1. Reinicie o Plasma: `systemctl --user restart plasma-plasmashell`.
2. Entre no modo de edição do painel e adicione o widget **Icon Drawer**.
3. Remova a **System Tray** nativa do mesmo painel.

Não mantenha as duas bandejas no mesmo painel, porque os ícones apareceriam
duas vezes. A nova bandeja começa com a configuração padrão. As escolhas
"Show only in popup" da bandeja nativa não são copiadas.

## Reversão

1. No modo de edição do painel, adicione de volta a **System Tray** nativa e
   remova o **Icon Drawer**.
2. Remova os arquivos instalados:
   `xargs -a build/install_manifest.txt sudo rm -f`.
3. Reinicie o Plasma.

## Testes realizados

Testes em um contêiner Fedora 44 com o `plasmoidviewer` do Plasma 6.7.5,
sobre Xvfb, com mouse simulado por `xdotool`:

- Compilação sem erros. O único aviso, uma variável não usada em
  `systemtray.cpp`, vem do código original.
- QML carregado sem erros no log.
- Arrastar o Volume do painel até a seta: a gaveta abre durante o arrasto, o
  ícone vai para a gaveta e a configuração grava `hiddenItems`.
- Arrastar *Disks & Devices* da gaveta até o painel: o painel mostra o espaço
  de soltar, o ícone vai para o painel e a configuração grava `shownItems`.
- Arrastar o ícone de um aplicativo (StatusNotifierItem) até a seta: o ícone
  vai para a gaveta.
- *Organize Drawer*: mostra o estado correto e move o Volume para a gaveta.
- Um clique simples continua abrindo o item, sem alterar a configuração.
- *Show Only Apps* (sessão Plasma aninhada em Wayland, com dois apps
  StatusNotifierItem de teste na gaveta, um de categoria *ApplicationStatus* e
  outro *SystemServices*): ligado pelo botão ou pela página de configuração, a
  gaveta mostra só o primeiro. Desligado, Notificações, Volume, Discos e o
  segundo app voltam. A configuração grava `hideSystemItemsInDrawer`. Depois de
  5 reinícios do plasmashell com a opção ligada, o botão continuou marcado e a
  seta apareceu. Fechando o app, a seta some; abrindo de novo com o filtro
  ligado, ele volta à gaveta.
- *Single color* (mesma sessão, com apps de teste usando os ícones reais do
  Claude, Spotifast, qBittorrent e Steam): os quatro viram glifos na cor do
  ícone de volume, escuros no Breeze claro e claros no Breeze escuro.

Ainda não foi testado em um painel real do Plasma sobre Wayland, nem com dois
monitores.

## Limitações

- O plugin precisa ser recompilado a cada atualização do Plasma, porque usa
  APIs internas da bandeja.
- Os textos novos (*Organize Drawer*, *Panel*, *Drawer*, *Auto*) estão em
  inglês. Os textos herdados da bandeja nativa também aparecem em inglês,
  porque o domínio de tradução mudou junto com o ID do plugin.
- Não é possível reordenar ícones dentro do painel. O arrasto só move ícones
  entre o painel e a gaveta.

## Origem e licença

- `src/`: System Tray do plasma-workspace 6.7.5, de Marco Martin, Konrad
  Materka e outros colaboradores do KDE. As mudanças deste fork estão no
  histórico do git, separadas da importação original.
- `third_party/libdbusmenuqt/`: libdbusmenuqt do plasma-workspace 6.7.5, que
  o Plasma não instala como biblioteca pública.
- `third_party/statusnotifierwatcher/` e `third_party/dbus/`: um header e uma
  interface D-Bus do plasma-workspace 6.7.5.

Distribuído sob GPL-2.0-or-later. Os arquivos originais mantêm suas licenças
SPDX (GPL-2.0-or-later ou LGPL-2.0-or-later). Os textos das licenças estão em
`LICENSES/`.
