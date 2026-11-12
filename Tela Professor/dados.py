import json
import os

PASTA = os.path.dirname(os.path.abspath(__file__))
ARQUIVO_TAREFAS = os.path.join(PASTA, "tarefas.json")
ARQUIVO_INTERACOES = os.path.join(PASTA, "interacoes.json")


def carregar_tarefas():
    try:
        with open(ARQUIVO_TAREFAS, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return {"proximo_numero": 1, "tarefas": []}


def salvar_tarefas(banco):
    with open(ARQUIVO_TAREFAS, "w", encoding="utf-8") as f:
        json.dump(banco, f, ensure_ascii=False, indent=2)


def buscar_tarefa(banco, numero):
    for tarefa in banco["tarefas"]:
        if tarefa["numero"] == numero:
            return tarefa
    return None


def carregar_interacoes():
    try:
        with open(ARQUIVO_INTERACOES, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return []


def interacoes_da_tarefa(interacoes, numero):
    lista = []
    for interacao in interacoes:
        if interacao["tarefa"] == numero:
            lista.append(interacao)
    return lista


def contar_alunos(interacoes):
    vistos = []
    for interacao in interacoes:
        if interacao["aluno"] not in vistos:
            vistos.append(interacao["aluno"])
    return len(vistos)
