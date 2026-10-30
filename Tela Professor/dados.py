import json
import os


def carregar_tarefas():
	# Se o arquivo não existe, devolve um banco novo e vazio
	if not os.path.exists("tarefas.json"):
		return {"proximo_numero": 1, "tarefas": []}
	with open("tarefas.json", encoding="utf-8") as arquivo:
		return json.load(arquivo)


def salvar_tarefas(banco):
	with open("tarefas.json", "w", encoding="utf-8") as arquivo:
		json.dump(banco, arquivo, indent=2, ensure_ascii=False)


def buscar_tarefa(banco, numero):
	for tarefa in banco["tarefas"]:
		if tarefa["numero"] == numero:
			return tarefa
	return None


def carregar_interacoes():
	if not os.path.exists("interacoes.json"):
		return []
	with open("interacoes.json", encoding="utf-8") as arquivo:
		return json.load(arquivo)


def interacoes_da_tarefa(interacoes, numero):
	resultado = []
	for interacao in interacoes:
		if interacao["tarefa"] == numero:
			resultado.append(interacao)
	return resultado


def contar_alunos(interacoes):
	alunos_vistos = []
	for interacao in interacoes:
		if interacao["aluno"] not in alunos_vistos:
			alunos_vistos.append(interacao["aluno"])
	return len(alunos_vistos)
