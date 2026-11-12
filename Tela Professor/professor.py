# Tela do professor: recebe um comando pelo input() e responde com print().
# Cada linha que chega ou sai é uma informação só.

import json
import os
import sys
from dados import carregar_tarefas, salvar_tarefas, buscar_tarefa, carregar_interacoes, interacoes_da_tarefa, contar_alunos
from skill import gerar_skill, apagar_skill

# Pasta onde ficam os PDFs das atividades (ao lado deste arquivo)
PASTA = os.path.dirname(os.path.abspath(__file__))
PASTA_PDFS = os.path.join(PASTA, "atividades")


# Lê linhas até a linha FIM e devolve uma lista com elas
def ler_ate_fim():
    linhas = []
    linha = input()
    while linha != "FIM":
        linhas.append(linha)
        linha = input()
    return linhas


# Lê o tipo da atividade e o que vem depois.
# Devolve três coisas: o tipo, a lista de questões e o caminho do PDF.
# Se for "pdf", não tem questões escritas; se for "texto", não tem PDF.
def ler_material():
    tipo = input()
    if tipo == "pdf":
        caminho = input()
        return tipo, [], caminho
    questoes = ler_ate_fim()
    return tipo, questoes, ""



def copiar_pdf(caminho_origem, numero):
    os.makedirs(PASTA_PDFS, exist_ok=True)
    nome = "tarefa-" + str(numero) + ".pdf"
    arquivo_lido = open(caminho_origem, "rb")
    conteudo = arquivo_lido.read()
    arquivo_lido.close()
    arquivo_novo = open(os.path.join(PASTA_PDFS, nome), "wb")
    arquivo_novo.write(conteudo)
    arquivo_novo.close()
    return "atividades/" + nome



def nome_do_aluno(email):
    caminho = os.path.join(PASTA, "..", "Tela Login", "usuarios.json")
    try:
        arquivo = open(caminho, "r", encoding="utf-8")
        usuarios = json.load(arquivo)
        arquivo.close()
    except (OSError, ValueError):
        return email
    for usuario in usuarios:
        if usuario["email"] == email:
            return usuario["nome"] + " (" + email + ")"
    return email



def apagar_pdf(tarefa):
    caminho_relativo = tarefa.get("pdf", "")
    if caminho_relativo != "":
        caminho = os.path.join(PASTA, caminho_relativo)
        if os.path.exists(caminho):
            os.remove(caminho)



comando = input()

if comando == "listar":
    banco = carregar_tarefas()
    for tarefa in banco["tarefas"]:
        print(tarefa["numero"])
        print(tarefa["titulo"])
        print(tarefa["ia"])
        print(tarefa["modelo"])
        print(tarefa["status"])

elif comando == "adicionar":
    titulo = input()
    descricao = input()
    instrucoes = ler_ate_fim()
    ia = input()
    modelo = input()
    tipo, questoes, caminho_pdf = ler_material()

    banco = carregar_tarefas()
    numero = banco["proximo_numero"]

    
    pdf = ""
    if tipo == "pdf":
        try:
            pdf = copiar_pdf(caminho_pdf, numero)
        except OSError:
            print("erro")
            sys.exit()

    banco["proximo_numero"] = numero + 1
    tarefa = {
        "numero": numero,
        "titulo": titulo,
        "descricao": descricao,
        "instrucoes": instrucoes,
        "ia": ia,
        "modelo": modelo,
        "skill": "tarefa-" + str(numero),
        "status": "aberta",
        "tipo": tipo,
        "questoes": questoes,
        "pdf": pdf,
    }
    banco["tarefas"].append(tarefa)
    salvar_tarefas(banco)
    gerar_skill(tarefa)
    print(numero)

elif comando == "mostrar":
    numero = int(input())
    banco = carregar_tarefas()
    tarefa = buscar_tarefa(banco, numero)
    if tarefa is None:
        print("erro")
    else:
        print(tarefa["titulo"])
        print(tarefa["descricao"])
        print(tarefa["ia"])
        print(tarefa["modelo"])
        print(tarefa["status"])

elif comando == "editar":
    numero = int(input())
    titulo = input()
    descricao = input()
    instrucoes = ler_ate_fim()
    ia = input()
    modelo = input()
    trocar_material = input()   # "sim" ou "nao"
    tipo = ""
    questoes = []
    caminho_pdf = ""
    if trocar_material == "sim":
        tipo, questoes, caminho_pdf = ler_material()

    banco = carregar_tarefas()
    tarefa = buscar_tarefa(banco, numero)
    if tarefa is None:
        print("erro")
    else:
        
        novo_pdf = None
        if trocar_material == "sim" and tipo == "pdf":
            try:
                novo_pdf = copiar_pdf(caminho_pdf, numero)
            except OSError:
                print("erro")
                sys.exit()

        apagar_skill(tarefa)
        tarefa["titulo"] = titulo
        tarefa["descricao"] = descricao
        tarefa["ia"] = ia
        tarefa["modelo"] = modelo
        if len(instrucoes) > 0:
            tarefa["instrucoes"] = instrucoes
        if trocar_material == "sim":
            
            if tarefa.get("pdf", "") != "" and tipo != "pdf":
                apagar_pdf(tarefa)
            tarefa["tipo"] = tipo
            tarefa["questoes"] = questoes
            if novo_pdf is not None:
                tarefa["pdf"] = novo_pdf
            else:
                tarefa["pdf"] = ""
        salvar_tarefas(banco)
        gerar_skill(tarefa)
        print("ok")

elif comando == "alternar":
    numero = int(input())
    banco = carregar_tarefas()
    tarefa = buscar_tarefa(banco, numero)
    if tarefa is None:
        print("erro")
    else:
        if tarefa["status"] == "aberta":
            tarefa["status"] = "encerrada"
        else:
            tarefa["status"] = "aberta"
        salvar_tarefas(banco)
        print(tarefa["status"])

elif comando == "apagar":
    numero = int(input())
    banco = carregar_tarefas()
    tarefa = buscar_tarefa(banco, numero)
    if tarefa is None:
        print("erro")
    else:
        apagar_skill(tarefa)
        apagar_pdf(tarefa)
        banco["tarefas"].remove(tarefa)
        salvar_tarefas(banco)
        print("ok")

elif comando == "resultados":
    numero = int(input())
    banco = carregar_tarefas()
    tarefa = buscar_tarefa(banco, numero)
    if tarefa is None:
        print("erro")
    else:
        lista = interacoes_da_tarefa(carregar_interacoes(), numero)
        print(len(lista))
        print(contar_alunos(lista))
        for interacao in lista:
            print(nome_do_aluno(interacao["aluno"]))
            print(interacao["pergunta"].replace("\n", " "))
            print(interacao["resposta"].replace("\n", " "))
