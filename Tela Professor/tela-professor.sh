#!/bin/bash

cd "$(dirname "$0")" || exit 1
source "../ui.sh"

MODELOS_CLAUDE=(haiku sonnet opus)
MODELOS_CODEX=(gpt-6.1-sol gpt-6-sol gpt-6-luna)

ERRO_GERAL="Não consegui fazer isso agora. Tenta de novo."


chamar() {
    mapfile -t SAIDA < <(printf '%s\n' "$@" | python3 professor.py)
}

cabecalho() {
    clear
    tput bold
    printf -- '--- %s ---\n' "$1"
    tput sgr0
}


perguntar() {
    printf '%s' "$1"
    IFS= read -r RESPOSTA || exit
}

pausar() {
    perguntar "(aperta Enter pra voltar)"
}


ler_numero() {
    while true; do
        perguntar "$1"
        if [[ $RESPOSTA =~ ^[0-9]+$ ]]; then
            NUMERO=$(( 10#$RESPOSTA ))
            return
        fi
        echo "Digita só o número, por favor."
    done
}


escolher() {
    while true; do
        perguntar "Escolha: "
        if [[ ! $RESPOSTA =~ ^[0-9]+$ ]]; then
            echo "Digita só o número, por favor."
        elif (( 10#$RESPOSTA < $1 || 10#$RESPOSTA > $2 )); then
            echo "Opção inválida, escolhe um número do menu."
        else
            OPCAO=$(( 10#$RESPOSTA ))
            return
        fi
    done
}

sim_ou_nao() {
    perguntar "$1"
    [[ $RESPOSTA == [sS] ]]
}

nao_achei() {
    echo "Não achei nenhuma tarefa com esse número."
    pausar
}


ler_instrucoes() {
    echo
    echo "Instruções pra IA (escreve quantas linhas quiser;"
    echo "digita FIM numa linha sozinha pra terminar):"
    INSTRUCOES=()
    while true; do
        perguntar "> "
        [[ $RESPOSTA == FIM ]] && return
        INSTRUCOES+=("$RESPOSTA")
    done
}


ler_questoes() {
    echo
    echo "Questões (uma linha por vez; alternativas em linhas separadas;"
    echo "digita FIM numa linha sozinha pra terminar):"
    QUESTOES=()
    while true; do
        perguntar "> "
        [[ $RESPOSTA == FIM ]] && return
        QUESTOES+=("$RESPOSTA")
    done
}


escolher_tipo() {
    echo
    echo "Tipo de atividade?"
    echo " 1. Questões escritas (abertas ou com alternativas)"
    echo " 2. PDF com as questões (abre com o display)"
    escolher 1 2
    if (( OPCAO == 1 )); then
        TIPO=texto
    else
        TIPO=pdf
    fi
}


ler_pdf() {
    while true; do
        perguntar "Caminho do PDF (ex.: ~/provas/lista1.pdf): "
        CAMINHO_PDF=${RESPOSTA/#\~/$HOME}
        if [[ -f $CAMINHO_PDF ]]; then
            return
        fi
        echo "Não achei esse arquivo. Confere o caminho."
    done
}


ler_material() {
    escolher_tipo
    if [[ $TIPO == pdf ]]; then
        ler_pdf
        QUESTOES=()
    else
        CAMINHO_PDF=""
        ler_questoes
    fi
}


escolher_ia_e_modelo() {
    local i
    echo
    echo "Qual IA?"
    echo " 1. Claude"
    echo " 2. Codex"
    escolher 1 2
    if (( OPCAO == 1 )); then
        IA=claude
        MODELOS=("${MODELOS_CLAUDE[@]}")
    else
        IA=codex
        MODELOS=("${MODELOS_CODEX[@]}")
    fi

    echo
    echo "Qual modelo?"
    for i in "${!MODELOS[@]}"; do
        echo " $(( i + 1 )). ${MODELOS[i]}"
    done
    escolher 1 "${#MODELOS[@]}"
    MODELO=${MODELOS[OPCAO - 1]}
}


coluna() {
    local texto=$2
    while (( ${#texto} < $1 )); do
        texto+=" "
    done
    printf '%s' "$texto"
}

linha_da_tabela() {
    printf ' '
    coluna 4 "$1"
    coluna $(( largura_titulo + 2 )) "$2"
    coluna 8 "$3"
    coluna $(( largura_modelo + 2 )) "$4"
    printf '%s\n' "$5"
}


mostrar_tabela() {
    local i largura_titulo=6 largura_modelo=6
    chamar listar
    for (( i = 0; i < ${#SAIDA[@]}; i += 5 )); do
        (( ${#SAIDA[i + 1]} > largura_titulo )) && largura_titulo=${#SAIDA[i + 1]}
        (( ${#SAIDA[i + 3]} > largura_modelo )) && largura_modelo=${#SAIDA[i + 3]}
    done

    linha_da_tabela "Nº" "Título" "IA" "Modelo" "Status"
    for (( i = 0; i < ${#SAIDA[@]}; i += 5 )); do
        linha_da_tabela "${SAIDA[@]:i:5}"
    done
}

adicionar_tarefa() {
    local titulo descricao
    cabecalho "ADICIONAR TAREFA"
    perguntar "Título: "
    titulo=$RESPOSTA
    perguntar "Descrição: "
    descricao=$RESPOSTA
    ler_instrucoes
    escolher_ia_e_modelo
    ler_material

    if [[ $TIPO == pdf ]]; then
        chamar adicionar "$titulo" "$descricao" "${INSTRUCOES[@]}" FIM "$IA" "$MODELO" "$TIPO" "$CAMINHO_PDF"
    else
        chamar adicionar "$titulo" "$descricao" "${INSTRUCOES[@]}" FIM "$IA" "$MODELO" "$TIPO" "${QUESTOES[@]}" FIM
    fi
    echo
    if [[ ${SAIDA[0]} =~ ^[0-9]+$ ]]; then
        echo "Prontinho! Tarefa ${SAIDA[0]} criada e skill instalada."
    else
        echo "$ERRO_GERAL"
    fi
    pausar
}

ver_resultados() {
    local titulo perguntas alunos i j aluno
    local -a vistos

    cabecalho "VER RESULTADOS"
    mostrar_tabela
    echo
    ler_numero "Número da tarefa: "

    chamar mostrar "$NUMERO"
    if [[ ${SAIDA[0]} == erro || ${#SAIDA[@]} -lt 5 ]]; then
        nao_achei
        return
    fi
    titulo=${SAIDA[0]}

    chamar resultados "$NUMERO"
    if [[ ! ${SAIDA[0]} =~ ^[0-9]+$ ]]; then
        echo "$ERRO_GERAL"
        pausar
        return
    fi

    cabecalho "RESULTADOS: $titulo"
    perguntas="${SAIDA[0]} perguntas"
    alunos="${SAIDA[1]} alunos"
    (( SAIDA[0] == 1 )) && perguntas="1 pergunta"
    (( SAIDA[1] == 1 )) && alunos="1 aluno"
    echo "$perguntas de $alunos"
    echo

    
    vistos=()
    for (( i = 2; i < ${#SAIDA[@]}; i += 3 )); do
        aluno=${SAIDA[i]}
        [[ " ${vistos[*]} " == *" $aluno "* ]] && continue
        vistos+=("$aluno")

        echo "[$aluno]"
        for (( j = i; j < ${#SAIDA[@]}; j += 3 )); do
            if [[ ${SAIDA[j]} == "$aluno" ]]; then
                echo "  P: ${SAIDA[j + 1]}"
                echo "  R: ${SAIDA[j + 2]}"
                echo
            fi
        done
    done
    pausar
}

editar_tarefa() {
    local titulo descricao
    ler_numero "Número da tarefa: "
    chamar mostrar "$NUMERO"
    if [[ ${SAIDA[0]} == erro || ${#SAIDA[@]} -lt 5 ]]; then
        nao_achei
        return
    fi
    titulo=${SAIDA[0]}
    descricao=${SAIDA[1]}
    IA=${SAIDA[2]}
    MODELO=${SAIDA[3]}

    echo
    echo "(Enter mantém o que já tá lá)"
    perguntar "Título [$titulo]: "
    [[ -n $RESPOSTA ]] && titulo=$RESPOSTA
    perguntar "Descrição [$descricao]: "
    [[ -n $RESPOSTA ]] && descricao=$RESPOSTA

    INSTRUCOES=()
    if sim_ou_nao "Quer reescrever as instruções? (s/n): "; then
        ler_instrucoes
    fi
    if sim_ou_nao "Quer trocar a IA ou o modelo? (s/n): "; then
        escolher_ia_e_modelo
    fi

    TROCAR_MATERIAL=nao
    if sim_ou_nao "Quer trocar as questões ou o PDF? (s/n): "; then
        TROCAR_MATERIAL=sim
        ler_material
    fi

    if [[ $TROCAR_MATERIAL == sim ]]; then
        if [[ $TIPO == pdf ]]; then
            chamar editar "$NUMERO" "$titulo" "$descricao" "${INSTRUCOES[@]}" FIM "$IA" "$MODELO" sim "$TIPO" "$CAMINHO_PDF"
        else
            chamar editar "$NUMERO" "$titulo" "$descricao" "${INSTRUCOES[@]}" FIM "$IA" "$MODELO" sim "$TIPO" "${QUESTOES[@]}" FIM
        fi
    else
        chamar editar "$NUMERO" "$titulo" "$descricao" "${INSTRUCOES[@]}" FIM "$IA" "$MODELO" nao
    fi
    echo
    if [[ ${SAIDA[0]} == ok ]]; then
        echo "Tarefa $NUMERO atualizada e skill refeita."
    else
        echo "$ERRO_GERAL"
    fi
    pausar
}

alternar_tarefa() {
    ler_numero "Número da tarefa: "
    chamar alternar "$NUMERO"
    if [[ ${SAIDA[0]} == aberta || ${SAIDA[0]} == encerrada ]]; then
        echo "Tarefa $NUMERO agora está ${SAIDA[0]}."
        pausar
    elif [[ ${SAIDA[0]} == erro ]]; then
        nao_achei
    else
        echo "$ERRO_GERAL"
        pausar
    fi
}

apagar_tarefa() {
    cabecalho "APAGAR TAREFA"
    ler_numero "Número da tarefa: "
    chamar mostrar "$NUMERO"
    if [[ ${SAIDA[0]} == erro || ${#SAIDA[@]} -lt 5 ]]; then
        nao_achei
        return
    fi

    if sim_ou_nao "Tem certeza que quer apagar \"${SAIDA[0]}\"? (s/n): "; then
        chamar apagar "$NUMERO"
        if [[ ${SAIDA[0]} == ok ]]; then
            echo "Tarefa apagada e skill removida."
        else
            echo "$ERRO_GERAL"
        fi
        pausar
    fi
}

gerenciar_tarefas() {
    while true; do
        cabecalho "GERENCIAR TAREFAS"
        mostrar_tabela
        echo
        echo "1. Editar tarefa"
        echo "2. Abrir / encerrar tarefa"
        echo "3. Apagar tarefa"
        echo "0. Voltar"
        escolher 0 3
        case $OPCAO in
            1) editar_tarefa ;;
            2) alternar_tarefa ;;
            3) apagar_tarefa ;;
            0) return ;;
        esac
    done
}


menu_principal() {
    clear
    ui_caixa 50 "ECLUSA · MENU DO PROFESSOR" \
        "" \
        "  1. Adicionar tarefa" \
        "  2. Ver resultados" \
        "  3. Gerenciar tarefas" \
        "" \
        "  0. Voltar ao login"
    tput cup "$UI_FIM" "$UI_ESQUERDA"
    echo
}


while true; do
    menu_principal
    escolher 0 3
    case $OPCAO in
        1) adicionar_tarefa ;;
        2) ver_resultados ;;
        3) gerenciar_tarefas ;;
        0) clear; exit 0 ;;
    esac
done
