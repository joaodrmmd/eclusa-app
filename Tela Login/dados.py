import json
import os

ARQUIVO_USUARIOS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "usuarios.json")


def carregar_usuarios():
    try:
        with open(ARQUIVO_USUARIOS, "r", encoding="utf-8") as arquivo:
            return json.load(arquivo)
    except (FileNotFoundError, json.JSONDecodeError):
        return []
