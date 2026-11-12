# Tela do aluno: recebe um comando pelo input() e responde com print().
# Cada linha que chega ou sai é uma informação só.

import os
from dados import carregar_tarefas, tarefas_abertas, buscar_tarefa_aberta, salvar_interacao
from ia import perguntar_ia

# Pasta da tela do professor (onde ficam os PDFs das atividades)
PASTA_PROFESSOR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "Tela Professor")

# O comando é a primeira linha que chega
comando = input()

if comando == "listar":
    banco = carregar_tarefas()
    for tarefa in tarefas_abertas(banco):
        print(tarefa["numero"])
        print(tarefa["titulo"])

elif comando == "entrar":
    numero = int(input())

    banco = carregar_tarefas()
    tarefa = buscar_tarefa_aberta(banco, numero)
    if tarefa is None:
        print("erro")
    else:
        print(tarefa["titulo"])
        print(tarefa["descricao"])
        print(tarefa["ia"])
        print(tarefa["modelo"])
        tipo = tarefa.get("tipo", "texto")
        print(tipo)
        # Depois do tipo vem o material:
        # - pdf: o caminho completo do arquivo
        # - texto: uma linha por questão
        if tipo == "pdf":
            caminho = os.path.join(PASTA_PROFESSOR, tarefa["pdf"])
            print(os.path.normpath(caminho))
        else:
            for questao in tarefa.get("questoes", []):
                print(questao)

# Registra a resposta do aluno na área de questões. Não chama a IA.
elif comando == "registrar":
    email = input()
    numero = int(input())
    resposta_aluno = input()

    banco = carregar_tarefas()
    tarefa = buscar_tarefa_aberta(banco, numero)
    if tarefa is None:
        print("erro")
    else:
        salvar_interacao(numero, email, resposta_aluno, "(resposta registrada na área de questões)")
        print("ok")

elif comando == "perguntar":
    email = input()
    numero = int(input())
    pergunta = input()

    banco = carregar_tarefas()
    tarefa = buscar_tarefa_aberta(banco, numero)
    if tarefa is None:
        print("erro")
    else:
        resposta = perguntar_ia(tarefa, pergunta)
        if resposta is None:
            print("sem-ia")
        else:
            salvar_interacao(numero, email, pergunta, resposta)
            print("ok")
            print(resposta)
