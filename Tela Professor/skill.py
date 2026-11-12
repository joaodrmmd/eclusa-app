import os

PASTA = os.path.dirname(os.path.abspath(__file__))
MOLDE = os.path.join(PASTA, "molde-skill.md")


def pasta_da_skill(tarefa):
    if tarefa["ia"] == "claude":
        base = os.path.expanduser("~/.claude/skills")
    else:
        base = os.path.expanduser("~/.codex/skills")
    return os.path.join(base, tarefa["skill"])


# Texto que descreve a atividade para a IA.
# Se for PDF, a IA não lê o arquivo: só sabe que a atividade está nele.
def texto_da_atividade(tarefa):
    if tarefa.get("tipo", "texto") == "pdf":
        return "A atividade está em um PDF que o aluno abre separadamente. O aluno responde só com a letra da alternativa."
    return "\n".join(tarefa.get("questoes", []))


def gerar_skill(tarefa):
    arquivo_molde = open(MOLDE, "r", encoding="utf-8")
    texto = arquivo_molde.read()
    arquivo_molde.close()

    texto = texto.replace("{skill}", tarefa["skill"])
    texto = texto.replace("{numero}", str(tarefa["numero"]))
    texto = texto.replace("{titulo}", tarefa["titulo"])
    texto = texto.replace("{descricao}", tarefa["descricao"])
    texto = texto.replace("{atividade}", texto_da_atividade(tarefa))
    texto = texto.replace("{instrucoes}", "\n".join(tarefa["instrucoes"]))

    pasta = pasta_da_skill(tarefa)
    os.makedirs(pasta, exist_ok=True)
    with open(os.path.join(pasta, "SKILL.md"), "w", encoding="utf-8") as f:
        f.write(texto)


def apagar_skill(tarefa):
    pasta = pasta_da_skill(tarefa)
    arquivo = os.path.join(pasta, "SKILL.md")
    if os.path.exists(arquivo):
        os.remove(arquivo)
    if os.path.exists(pasta):
        os.rmdir(pasta)
