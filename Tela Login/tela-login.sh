#!/bin/bash
# Tela de login do ECLUSA
# Confere o e-mail e a senha no login.py e abre a tela certa (professor ou aluno)

cd "$(dirname "$0")" || exit 1

LARGURA=49           
ALTURA=16            
TAMANHO_CAMPO=35     


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


fazer_login() {
    clear
    posicionar
    desenhar_logo
    desenhar_caixa

    while true; do
        ler_campo "$LINHA_EMAIL" "$COLUNA_CAMPO"
        email=$CAMPO

        ler_campo "$LINHA_SENHA" "$COLUNA_CAMPO" senha
        senha=$CAMPO

        resposta=$(printf '%s\n%s\n' "$email" "$senha" | python3 login.py)
        if [[ -n $resposta && $resposta != erro ]]; then
            IFS=';' read -r tipo nome <<< "$resposta"
            return
        fi

        
        clear
        posicionar
        desenhar_logo
        desenhar_caixa
        escrever "$FIM" 0 "E-mail ou senha errados. Tenta de novo."
    done
}


while true; do
    fazer_login
    clear
    echo "Oi, $nome!"
    sleep 1

    if [[ $tipo == professor ]]; then
        bash "../Tela Professor/tela-professor.sh"
    else
        bash "../Tela Aluno/tela-aluno.sh" "$email"
    fi
done