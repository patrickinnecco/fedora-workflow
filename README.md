# linux-showdesktop

Widget exibido no Plasma como **Scadutree Show Desktop**. O ID interno
`com.scadutree.showdesktop` permanece estável para preservar o botão já
instalado no painel.

Plasmoide para Plasma 6. A faixa de 8 pixels lógicos usa a propriedade pública
`KWindowSystem.showingDesktop` para ativar ou desativar o modo Show Desktop do
KWin. O KWin preserva as janelas e aplica o modo a todos os monitores.

O painel do Plasma reserva uma margem à direita do último applet. O widget
desenha a linha logo à direita da área clicável, reduzindo o vão visual depois
do relógio. Como o painel não encaminha cliques na margem externa ao applet,
a área clicável de 8 pixels fica dentro da célula, à esquerda da linha. Quando
o KWin mostra o desktop e o painel flutua, a linha recua para dentro da célula
e continua visível. A posição e a altura seguem diretamente o progresso de
animação do próprio painel do Plasma 6.7.5.
A área clicável não recebe preenchimento colorido ao passar o mouse. Não há
janela auxiliar nem serviço em segundo plano.

## Arquivos

- `package/metadata.json`: registro do plasmoide.
- `package/contents/ui/main.qml`: interface e ação do botão.

## Instalação

No diretório clonado, instale com
`kpackagetool6 --type Plasma/Applet --install package`. Para atualizar, use
`--upgrade package`. O arquivo `.plasmoid` disponibilizado no repositório
contém o mesmo conteúdo do diretório `package`.

## Ajuste visual

A faixa usa as cores do tema Plasma. A linha divisória ocupa a altura visível
do painel atual. Para alterar a largura da área clicável, ajuste os valores
de largura do applet em `main.qml`.

## Remoção

Primeiro remova o widget do painel pelo modo de edição. Depois execute
`kpackagetool6 --type Plasma/Applet --remove com.scadutree.showdesktop`.
