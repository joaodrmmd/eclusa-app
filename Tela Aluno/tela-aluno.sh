#!/bin/bash
# Tela do aluno do ECLUSA (a funcionalidade fica no aluno.py)
# Uso: ./tela-aluno.sh [email-do-aluno]
#
# A tela tem duas áreas separadas:
#   - CHAT: conversa livre com a IA (campo "Você:")
#   - QUESTÕES: as questões da tarefa e a resposta do aluno (campo "Sua resposta:")

cd "$(dirname "$0")" || exit 1
source "../ui.sh"

EMAIL=${1:-aluno@instituicao.com.br}
ERRO_GERAL="Não consegui fazer isso agora. Tenta de novo."

# Manda cada argumento como uma linha pro aluno.py e guarda cada linha da resposta em SAIDA
chamar() {
    mapfile -t SAIDA < <(printf '%s\n' "$@" | python3 aluno.py)
}

# Mostra a pergunta e guarda o que foi digitado em RESPOSTA
perguntar() {
    printf '%s' "$1"
    IFS= read -r RESPOSTA || exit
}

pausar() {
    perguntar "(aperta Enter pra voltar)"
}

# Repete o "Escolha:" até a pessoa escolher uma opção entre $1 e $2. Guarda em OPCAO.
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

# Desenha o menu no centro da tela
menu_principal() {
    clear
    ui_caixa 50 "ECLUSA · MENU DO ALUNO" \
        "" \
        "  1. Ver tarefas abertas" \
        "" \
        "  0. Voltar ao login"
    tput cup "$UI_FIM" "$UI_ESQUERDA"
    echo
}

# Lista as tarefas abertas e pergunta qual abrir. Enter volta ao menu. Guarda em NUMERO.
ver_tarefas() {
    local i
    clear
    tput bold
    echo "--- TAREFAS ABERTAS ---"
    tput sgr0
    chamar listar
    if (( ${#SAIDA[@]} == 0 )); then
        echo "Nenhuma tarefa aberta no momento."
        pausar
        return
    fi
    for (( i = 0; i < ${#SAIDA[@]}; i += 2 )); do
        echo "  ${SAIDA[i]}. ${SAIDA[i + 1]}"
    done
    echo

    perguntar "Número da tarefa pra abrir (Enter volta): "
    [[ -z $RESPOSTA ]] && return
    if [[ $RESPOSTA =~ ^[0-9]+$ ]]; then
        NUMERO=$(( 10#$RESPOSTA ))
    else
        echo "Digita só o número, por favor."
        pausar
    fi
}

# Escreve uma mensagem: nome colorido, texto (pode ter várias linhas) e uma linha em branco.
#   $1 = "aluno" ou "ia"   $2 = texto
imprimir_mensagem() {
    local quem=$1 texto=$2 linha primeira=1
    if [[ $quem == aluno ]]; then
        tput setaf 2     # verde
        printf 'Você: '
    else
        tput setaf 6     # azul-claro
        printf 'IA: '
    fi
    tput sgr0
    while IFS= read -r linha; do
        if (( primeira )); then
            printf '%s\n' "$linha"
            primeira=0
        else
            printf '      %s\n' "$linha"
        fi
    done <<< "$texto"
    echo
}

# Mostra o aviso da última ação (se tiver)
mostrar_aviso() {
    if [[ -n $MENSAGEM ]]; then
        tput setaf 3     # amarelo
        echo "$MENSAGEM"
        tput sgr0
        echo
    fi
}

# Cabeçalho da tarefa, igual nas duas áreas
cabecalho_tarefa() {
    tput bold
    echo "Tarefa $NUMERO: $TITULO"
    tput sgr0
    echo "IA desta tarefa: $NOME_IA ($MODELO), configurada pelo professor"
    echo
}

# ---------- ÁREA 1: CHAT (só conversa com a IA) ----------

desenhar_chat() {
    local i
    clear
    cabecalho_tarefa
    echo "──────────────── CHAT ────────────────"
    echo

    for (( i = 0; i < ${#CHAT_QUEM[@]}; i++ )); do
        imprimir_mensagem "${CHAT_QUEM[i]}" "${CHAT_TXT[i]}"
    done
    mostrar_aviso

    tput setaf 3
    tput bold
    echo "Teclas: [Ctrl+T] responder questões   [Esc] voltar ao menu do aluno"
    tput sgr0
    echo
    printf 'Você: '
}

# ---------- ÁREA 2: QUESTÕES (questões e resposta do aluno) ----------

abrir_pdf() {
    if command -v display >/dev/null 2>&1; then
        display "${MATERIAL[0]}" </dev/null >/dev/null 2>&1 &
        MENSAGEM="PDF aberto no visualizador."
    else
        MENSAGEM="Comando display não encontrado. Avisa o professor."
    fi
}

desenhar_questoes() {
    local i linha
    clear
    cabecalho_tarefa
    echo "──────────────── QUESTÕES ────────────────"
    echo

    if [[ $TIPO == pdf ]]; then
        echo "A atividade está no PDF. Responda só com a letra da alternativa."
    else
        for linha in "${MATERIAL[@]}"; do
            echo "  $linha"
        done
    fi
    echo

    for (( i = 0; i < ${#QUEST_QUEM[@]}; i++ )); do
        imprimir_mensagem "${QUEST_QUEM[i]}" "${QUEST_TXT[i]}"
    done
    mostrar_aviso

    tput setaf 3
    tput bold
    echo "Teclas: [Enter] enviar   [Ctrl+O] abrir PDF   [Esc] voltar pro chat"
    tput sgr0
    echo
    if [[ $TIPO == pdf ]]; then
        printf 'Sua resposta (só a letra): '
    else
        printf 'Sua resposta: '
    fi
}

# Tela de questões: só mexe nas respostas dela. Devolve 1 se a tarefa foi encerrada.
tela_questoes() {
    local pergunta
    MENSAGEM=""
    [[ $TIPO == pdf ]] && abrir_pdf

    while true; do
        desenhar_questoes
        ler_linha
        case $LINHA in
            __VOLTAR__)
                MENSAGEM=""
                return 0
                ;;
            __PDF__)
                if [[ $TIPO == pdf ]]; then
                    abrir_pdf
                fi
                ;;
            __QUESTOES__|"") ;;                       # Ctrl+T aqui não faz nada; Enter vazio não envia
            *)
                # Resposta de questão: só registra, sem chamar a IA e sem mostrar nada da IA
                chamar registrar "$EMAIL" "$NUMERO" "$LINHA"
                if [[ ${SAIDA[0]} == ok ]]; then
                    QUEST_QUEM+=("aluno"); QUEST_TXT+=("$LINHA")
                    MENSAGEM="Resposta registrada."
                else
                    MENSAGEM="Essa tarefa não está mais aberta."
                    desenhar_questoes
                    pausar
                    return 1
                fi
                ;;
        esac
    done
}

# ---------- ENVIO E LEITURA DE TECLAS ----------

# Manda a pergunta para a IA e guarda as duas mensagens na área indicada ($3: chat ou questoes).
# Devolve 1 se a tarefa não está mais aberta.
enviar() {
    local texto=$1 pergunta=$2 destino=$3 resposta="" i
    chamar perguntar "$EMAIL" "$NUMERO" "$pergunta"
    case ${SAIDA[0]} in
        ok)
            for (( i = 1; i < ${#SAIDA[@]}; i++ )); do
                resposta+="${SAIDA[i]}"$'\n'
            done
            resposta=${resposta%$'\n'}
            if [[ $destino == chat ]]; then
                CHAT_QUEM+=("aluno"); CHAT_TXT+=("$texto")
                CHAT_QUEM+=("ia");    CHAT_TXT+=("$resposta")
            else
                QUEST_QUEM+=("aluno"); QUEST_TXT+=("$texto")
                QUEST_QUEM+=("ia");    QUEST_TXT+=("$resposta")
            fi
            MENSAGEM=""
            ;;
        erro)
            MENSAGEM="Essa tarefa não está mais aberta."
            return 1
            ;;
        sem-ia)
            MENSAGEM="Não consegui falar com a IA agora. Tenta de novo daqui a pouco."
            ;;
        *)
            MENSAGEM="$ERRO_GERAL"
            ;;
    esac
    return 0
}

# Lê uma linha digitada, uma tecla por vez. Guarda em LINHA.
# Ctrl+T -> __QUESTOES__   Ctrl+O -> __PDF__   Esc sozinho -> __VOLTAR__
ler_linha() {
    local c resto
    LINHA=""
    while IFS= read -r -s -n1 c; do
        if [[ -z $c ]]; then                       # Enter
            printf '\n'
            return
        elif [[ $c == $'\x14' ]]; then             # Ctrl+T
            LINHA=__QUESTOES__
            printf '\n'
            return
        elif [[ $c == $'\x0f' ]]; then             # Ctrl+O
            LINHA=__PDF__
            printf '\n'
            return
        elif [[ $c == $'\e' ]]; then
            # Seta e outras teclas especiais mandam mais caracteres logo depois: ignora.
            # Esc sozinho não manda nada depois, então o read desiste e é o botão de voltar.
            if read -r -s -n2 -t 0.05 resto; then
                continue
            fi
            LINHA=__VOLTAR__
            printf '\n'
            return
        elif [[ $c == $'\177' || $c == $'\b' ]]; then   # apagar
            if [[ -n $LINHA ]]; then
                LINHA=${LINHA%?}
                printf '\b \b'
            fi
        elif [[ $c != [[:cntrl:]] ]]; then
            LINHA+=$c
            printf '%s' "$c"
        fi
    done
    printf '\n'
}

# Menu de resposta (Ctrl+T no chat). Devolve 0 pra continuar no chat, 1 pra voltar ao menu do aluno.
menu_resposta() {
    clear
    ui_caixa 60 "MENU DE RESPOSTA" \
        "" \
        "  1. Responder questões" \
        "  2. Voltar pro chat" \
        "  3. Voltar ao menu do aluno" \
        ""
    tput cup "$UI_FIM" "$UI_ESQUERDA"
    echo
    escolher 1 3
    case $OPCAO in
        1)
            tela_questoes
            # se a tarefa foi encerrada, sai da conversa; senão volta pro chat
            if [[ $? -eq 1 ]]; then
                return 1
            fi
            return 0
            ;;
        2) return 0 ;;
        3) return 1 ;;
    esac
}

# ---------- CONVERSA DA TAREFA ----------

# Abre a tarefa: chat com a IA. Esc volta ao menu do aluno.
conversar() {
    local numero=$1
    chamar entrar "$numero"
    if [[ ${SAIDA[0]} == erro || ${#SAIDA[@]} -lt 5 ]]; then
        echo "Não achei nenhuma tarefa com esse número."
        pausar
        return
    fi

    NUMERO=$numero
    TITULO=${SAIDA[0]}
    DESCRICAO=${SAIDA[1]}
    MODELO=${SAIDA[3]}
    TIPO=${SAIDA[4]}
    MATERIAL=("${SAIDA[@]:5}")          # o que vem depois do tipo: PDF ou questões
    case ${SAIDA[2]} in
        claude) NOME_IA=Claude ;;
        gemini) NOME_IA=Gemini ;;
        *) NOME_IA=Codex ;;
    esac

    CHAT_QUEM=()
    CHAT_TXT=()
    QUEST_QUEM=()
    QUEST_TXT=()
    MENSAGEM=""

    while true; do
        desenhar_chat
        ler_linha
        case $LINHA in
            __VOLTAR__) return ;;
            __QUESTOES__)
                if ! menu_resposta; then
                    return
                fi
                ;;
            __PDF__) ;;                             # Ctrl+O só funciona nas questões
            "") ;;                                  # Enter vazio: não manda nada
            *)
                if ! enviar "$LINHA" "$LINHA" chat; then
                    desenhar_chat
                    pausar
                    return
                fi
                ;;
        esac
    done
}

# Abre o menu e roda a opção escolhida. Sai quando a pessoa escolhe 0 (volta ao login).
while true; do
    menu_principal
    escolher 0 1
    case $OPCAO in
        1)
            ver_tarefas
            if [[ -n $NUMERO ]]; then
                conversar "$NUMERO"
            fi
            NUMERO=""
            ;;
        0) clear; exit 0 ;;
    esac
done
