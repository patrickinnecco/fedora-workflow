# Scadutree Show Desktop

Plasmoide para Plasma 6. A faixa de 8 pixels lógicos usa a propriedade pública
`KWindowSystem.showingDesktop` para ativar ou desativar o modo Show Desktop do
KWin. O KWin preserva as janelas e aplica o modo a todos os monitores.

Quando é o último applet do painel, a faixa ocupa a margem direita reservada
pelo Plasma e encosta na borda da tela. Em outras posições, permanece dentro
da sua célula de 8 pixels.

## Arquivos

- `package/metadata.json`: registro do plasmoide.
- `package/contents/ui/main.qml`: interface e ação do botão.

## Instalação

No diretório clonado, instale com
`kpackagetool6 --type Plasma/Applet --install package`. Para atualizar, use
`--upgrade package`. O arquivo `.plasmoid` disponibilizado no repositório
contém o mesmo conteúdo do diretório `package`.

## Ajuste visual

Altere os quatro valores de largura em `main.qml` para ajustar a faixa.
As cores vêm do tema Plasma. A linha divisória fica à esquerda da faixa.

## Remoção

Primeiro remova o widget do painel pelo modo de edição. Depois execute
`kpackagetool6 --type Plasma/Applet --remove com.scadutree.showdesktop`.
