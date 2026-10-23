# Scadutree Show Desktop

Plasmoide para Plasma 6. A faixa de 8 pixels lógicos usa a propriedade pública
`KWindowSystem.showingDesktop` para ativar ou desativar o modo Show Desktop do
KWin. O KWin preserva as janelas e aplica o modo a todos os monitores.

O painel do Plasma reserva uma margem à direita do último applet. QML pode
desenhar nessa margem, mas o painel não encaminha cliques para fora da célula
do applet. Para ter uma faixa realmente clicável na borda física, o widget
cria uma pequena superfície Wayland com o módulo `org.kde.layershell` do KDE.
Ela pertence ao próprio plasmoide, não reserva espaço de tela, não recebe foco
de teclado e desaparece quando o plasmoide é removido. A célula original de
8 pixels continua aceitando cliques como reserva. Quando o KWin mostra o
desktop e o painel flutua, a faixa recua 8 pixels para acompanhar sua borda.

## Arquivos

- `package/metadata.json`: registro do plasmoide.
- `package/contents/ui/main.qml`: interface e ação do botão.

## Instalação

No diretório clonado, instale com
`kpackagetool6 --type Plasma/Applet --install package`. Para atualizar, use
`--upgrade package`. O arquivo `.plasmoid` disponibilizado no repositório
contém o mesmo conteúdo do diretório `package`.

## Ajuste visual

A faixa usa as cores do tema Plasma. A linha divisória fica à esquerda dela.
Para alterar a largura, ajuste `implicitWidth` do applet e `width` da janela
`edgeWindow` em `main.qml`.

## Remoção

Primeiro remova o widget do painel pelo modo de edição. Depois execute
`kpackagetool6 --type Plasma/Applet --remove com.scadutree.showdesktop`.
