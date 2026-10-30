from dados import funcoes de gerenciamento de tarefas
from skill import funcoes de geração de gerenciamento de skills

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
    instrucoes = []
    linha = input()
    while linha != "FIM":
        instrucoes.append(linha)
        linha = input()
    ia = input()
    modelo = input()

    banco = carregar_tarefas()
    numero = banco["proximo_numero"]
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
    instrucoes = []
    linha = input()
    while linha != "FIM":
        instrucoes.append(linha)
        linha = input()
    ia = input()
    modelo = input()

    banco = carregar_tarefas()
    tarefa = buscar_tarefa(banco, numero)
    if tarefa is None:
        print("erro")
    else:
        apagar_skill(tarefa)
        tarefa["titulo"] = titulo
        tarefa["descricao"] = descricao
        tarefa["ia"] = ia
        tarefa["modelo"] = modelo
        if len(instrucoes) > 0:
            tarefa["instrucoes"] = instrucoes
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
            print(interacao["aluno"])
            print(interacao["pergunta"].replace("\n", " "))
            print(interacao["resposta"].replace("\n", " "))
