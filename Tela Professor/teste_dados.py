from dados import (
	carregar_tarefas, salvar_tarefas, buscar_tarefa,
	carregar_interacoes, interacoes_da_tarefa, contar_alunos,
)
import os

# Garante que começamos sem arquivo
if os.path.exists("tarefas.json"):
	os.remove("tarefas.json")

# Teste 1: sem arquivo, deve devolver o banco vazio
banco = carregar_tarefas()
print("Teste 1 (banco vazio):", banco)
# Esperado: {'proximo_numero': 1, 'tarefas': []}

# Teste 2: colocar uma tarefa, salvar, carregar de novo
banco["tarefas"].append({
	"numero": 1,
	"titulo": "Recursão",
	"descricao": "Fazer a função de fatorial",
	"instrucoes": ["Não dá o código pronto."],
	"ia": "claude",
	"modelo": "haiku",
	"skill": "tarefa-1",
	"status": "aberta",
})
banco["proximo_numero"] = 2
salvar_tarefas(banco)
banco = carregar_tarefas()
print("Teste 2 (tarefa salva):", banco)
# Esperado: a tarefa 1 aparece. Abra o tarefas.json e confira com os olhos.

# Teste 3: buscar_tarefa
print("Teste 3a (existe):", buscar_tarefa(banco, 1))   # a tarefa
print("Teste 3b (não existe):", buscar_tarefa(banco, 99))  # None

# Teste 4: interacoes_da_tarefa
interacoes = carregar_interacoes()
print("Teste 4a:", len(interacoes_da_tarefa(interacoes, 1)))   # 2
print("Teste 4b:", interacoes_da_tarefa(interacoes, 99))       # []

# Teste 5: contar_alunos
print("Teste 5:", contar_alunos(interacoes))  # 1

# Teste 6: apagar o arquivo e carregar não pode dar erro
os.remove("tarefas.json")
print("Teste 6 (sem erro):", carregar_tarefas())
