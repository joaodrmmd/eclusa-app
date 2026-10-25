#!/bin/bash
# Tela de login do ECLUSA (só a tela, sem backend)

LARGURA=49           # largura da logo e da caixa
ALTURA=16            # logo (6) + espaço (1) + caixa (7) + espaço (1) + dica (1)
TAMANHO_CAMPO=35     # quantos caracteres cabem em cada campo dentro da caixa

# Calcula onde a tela começa pra ficar no meio do terminal
posicionar() {
    TOPO=$(( ($(tput lines) - ALTURA) / 2 ))
    ESQUERDA=$(( ($(tput cols) - LARGURA) / 2 ))
    (( TOPO < 0 )) && TOPO=0
    (( ESQUERDA < 0 )) && ESQUERDA=0
    LINHA_EMAIL=$(( TOPO + 9 ))
    LINHA_SENHA=$(( TOPO + 11 ))
    COLUNA_CAMPO=$(( ESQUERDA + 11 ))
    FIM=$(( TOPO + ALTURA ))
}

# Escreve um texto na linha $1, deslocado $2 colunas a partir da esquerda da tela
escrever() {
    tput cup "$1" $(( ESQUERDA + $2 ))
    printf '%s' "$3"
}

desenhar_logo() {
    local i=0 linha
    tput bold
    while IFS= read -r linha; do
        escrever $(( TOPO + i )) 0 "$linha"
        i=$(( i + 1 ))
    done << 'EOF'
███████╗ ██████╗██╗     ██╗   ██╗███████╗ █████╗
██╔════╝██╔════╝██║     ██║   ██║██╔════╝██╔══██╗
█████╗  ██║     ██║     ██║   ██║███████╗███████║
██╔══╝  ██║     ██║     ██║   ██║╚════██║██╔══██║
███████╗╚██████╗███████╗╚██████╔╝███████║██║  ██║
╚══════╝ ╚═════╝╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
EOF
    tput sgr0
}

desenhar_caixa() {
    local i
    escrever $(( TOPO + 7 ))  0 "┌──────────────────── LOGIN ────────────────────┐"
    for i in 8 9 10 11 12; do
        escrever $(( TOPO + i )) 0 "│                                               │"
    done
    escrever $(( TOPO + 13 )) 0 "└───────────────────────────────────────────────┘"

    escrever "$LINHA_EMAIL" 0 "│  E-mail:"
    escrever "$LINHA_SENHA" 0 "│  Senha:"

    tput dim
    escrever $(( TOPO + 15 )) 11 "Enter confirma · Ctrl+C sai"
    tput sgr0
}

# Lê um campo na posição $1,$2. Se $3 for "senha", mostra * no lugar das letras.
# O que foi digitado fica em CAMPO.
ler_campo() {
    local c
    CAMPO=""
    tput cup "$1" "$2"
    while IFS= read -r -s -n1 c; do
        if [[ -z $c ]]; then
            break
        elif [[ $c == $'\177' || $c == $'\b' ]]; then
            if [[ -n $CAMPO ]]; then
                CAMPO=${CAMPO%?}
                printf '\b \b'
            fi
        elif [[ $c == $'\e' ]]; then
            read -r -s -n2 -t 0.01 c   # ignora setas e outras teclas especiais
        elif [[ $c != [[:cntrl:]] ]] && (( ${#CAMPO} < TAMANHO_CAMPO )); then
            CAMPO+=$c
            if [[ $3 == senha ]]; then
                printf '*'
            else
                printf '%s' "$c"
            fi
        fi
    done
}

sair() {
    tput cup "$FIM" 0
    echo
    exit
}

trap sair INT

clear
posicionar
desenhar_logo
desenhar_caixa

ler_campo "$LINHA_EMAIL" "$COLUNA_CAMPO"
email=$CAMPO

ler_campo "$LINHA_SENHA" "$COLUNA_CAMPO" senha
senha=$CAMPO

sair