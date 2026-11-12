import json
import os

PASTA_PROFESSOR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "Tela Professor")
ARQUIVO_TAREFAS = os.path.join(PASTA_PROFESSOR, "tarefas.json")
ARQUIVO_INTERACOES = os.path.join(PASTA_PROFESSOR, "interacoes.json")


def carregar_tarefas():
    try:
        with open(ARQUIVO_TAREFAS, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return {"proximo_numero": 1, "tarefas": []}


def tarefas_abertas(banco):
    abertas = []
    for tarefa in banco["tarefas"]:
        if tarefa["status"] == "aberta":
            abertas.append(tarefa)
    return abertas


def buscar_tarefa_aberta(banco, numero):
    for tarefa in banco["tarefas"]:
        if tarefa["numero"] == numero and tarefa["status"] == "aberta":
            return tarefa
    return None


def carregar_interacoes():
    try:
        with open(ARQUIVO_INTERACOES, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return []


def salvar_interacao(numero_tarefa, aluno, pergunta, resposta):
    interacoes = carregar_interacoes()
    maior = 0
    for inter in interacoes:
        if inter["numero"] > maior:
            maior = inter["numero"]
    interacoes.append({
        "numero": maior + 1,
        "tarefa": numero_tarefa,
        "aluno": aluno,
        "pergunta": pergunta,
        "resposta": resposta,
    })
    with open(ARQUIVO_INTERACOES, "w", encoding="utf-8") as f:
        json.dump(interacoes, f, ensure_ascii=False, indent=2)
