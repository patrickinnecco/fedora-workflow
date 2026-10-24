# linux-showdesktop

Widget exibido no Plasma como **Scadutree Show Desktop**. O ID interno
`com.scadutree.showdesktop` permanece estável para preservar o botão já
instalado no painel.

Plasmoide para Plasma 6. O botão usa a propriedade pública
`KWindowSystem.showingDesktop` para ativar ou desativar o modo Show Desktop do
KWin. O KWin preserva as janelas e aplica o modo a todos os monitores.

O painel do Plasma reserva uma margem à direita do último applet e redireciona
os cliques feitos nela para dentro da linha de applets, à esquerda da linha
divisória. A linha é apenas um divisor visual. Uma superfície Wayland
transparente cobre a seção visível entre a linha e a borda direita do painel
e recebe os cliques; nenhum pixel da linha ou à sua esquerda aciona o Show
Desktop. A posição e o tamanho dessa área são calculados a partir da linha,
do fundo do painel e do monitor do painel. Quando o painel flutua, a linha e
a área seguem diretamente o progresso da animação do Plasma 6.7.5. A área
clicável não recebe preenchimento colorido ao passar o mouse. A superfície
pertence ao plasmoide e não executa serviço separado.

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
do painel atual. A área clicável vai da linha até a borda direita do painel.

## Remoção

Primeiro remova o widget do painel pelo modo de edição. Depois execute
`kpackagetool6 --type Plasma/Applet --remove com.scadutree.showdesktop`.
