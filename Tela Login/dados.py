import json

def carregar_usuarios():
    try:
        with open("usuarios.json", "r", encoding="utf-8") as arquivo:
            return json.load(arquivo)
    except FileNotFoundError:
        print("Arquivo usuarios.json não encontrado.")
        return []
    except json.JSONDecodeError:
        print("O usuarios.json está quebrado. Confira vírgulas e aspas.")
        return []