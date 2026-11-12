#!/bin/bash
# Funções de desenho compartilhadas pelas telas do ECLUSA.
# Cada função tem um comentário dizendo o que ela faz.

# Repete um caractere $1 vezes $2. Ex.: ui_repetir "=" 5  ->  =====
ui_repetir() {
    local caractere=$1
    local quantidade=$2
    local resultado=""
    local i
    for (( i = 0; i < quantidade; i++ )); do
        resultado+=$caractere
    done
    printf '%s' "$resultado"
}

# Escreve o texto $1 completado com espaços até ter $2 letras
ui_preencher() {
    local texto=$1
    while (( ${#texto} < $2 )); do
        texto+=" "
    done
    printf '%s' "$texto"
}

# Desenha uma caixa no centro da tela.
#   $1 = largura da caixa
#   $2 = título (aparece no topo, centralizado)
#   $3 em diante = as linhas de dentro da caixa
# Depois de chamar, a variável UI_FIM tem a linha logo abaixo da caixa.
ui_caixa() {
    local largura=$1
    local titulo=$2
    shift 2
    local linhas=("$@")
    local altura=$(( ${#linhas[@]} + 4 ))   # topo, título, separador, linhas e base

    local topo=$(( ($(tput lines) - altura) / 2 ))
    local esquerda=$(( ($(tput cols) - largura) / 2 ))
    (( topo < 0 )) && topo=0
    (( esquerda < 0 )) && esquerda=0

    local dentro=$(( largura - 4 ))     # espaço útil dentro da caixa
    local i pad_titulo

    # Linha de cima
    tput cup "$topo" "$esquerda"
    tput setaf 6
    printf '╔%s╗' "$(ui_repetir "═" $(( largura - 2 )))"

    # Título centralizado
    pad_titulo=$(( (dentro - ${#titulo}) / 2 ))
    tput cup $(( topo + 1 )) "$esquerda"
    printf '║ %s%s%s ║' "$(ui_repetir " " "$pad_titulo")" "$(tput bold)$titulo$(tput sgr0)$(tput setaf 6)" "$(ui_repetir " " $(( dentro - pad_titulo - ${#titulo} )))"

    # Separador
    tput cup $(( topo + 2 )) "$esquerda"
    printf '╠%s╣' "$(ui_repetir "═" $(( largura - 2 )))"

    # Linhas de dentro
    for (( i = 0; i < ${#linhas[@]}; i++ )); do
        tput cup $(( topo + 3 + i )) "$esquerda"
        printf '║ %s ║' "$(ui_preencher "${linhas[i]}" "$dentro")"
    done

    # Linha de baixo
    tput cup $(( topo + altura - 1 )) "$esquerda"
    printf '╚%s╝' "$(ui_repetir "═" $(( largura - 2 )))"
    tput sgr0

    UI_FIM=$(( topo + altura ))
    UI_ESQUERDA=$esquerda
}
