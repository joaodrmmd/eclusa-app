import os
import subprocess


def pasta_da_skill(tarefa):
    if tarefa["ia"] == "claude":
        base = os.path.expanduser("~/.claude/skills")
    else:
        base = os.path.expanduser("~/.codex/skills")
    return os.path.join(base, tarefa["skill"])


def skill_instalada(tarefa):
    return os.path.exists(os.path.join(pasta_da_skill(tarefa), "SKILL.md"))


def montar_comando(tarefa, pergunta):
    if tarefa["ia"] == "claude":
        return ["claude", "-p", "/" + tarefa["skill"] + " " + pergunta,
                "--model", tarefa["modelo"], "--tools", "", "--no-session-persistence"]
    return ["codex", "exec", "--model", tarefa["modelo"], "--sandbox", "read-only",
            "--skip-git-repo-check", "--ephemeral", "--color", "never",
            "--disable", "shell_tool", "--disable", "unified_exec",
            "$" + tarefa["skill"] + " " + pergunta]


def perguntar_ia(tarefa, pergunta):
    if not skill_instalada(tarefa):
        return None
    try:
        resultado = subprocess.run(
            montar_comando(tarefa, pergunta),
            capture_output=True,
            encoding="utf-8",
            stdin=subprocess.DEVNULL,
            timeout=120,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None
    if resultado.returncode != 0:
        return None
    texto = resultado.stdout.strip()
    if texto == "":
        return None
    return texto
