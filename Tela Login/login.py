### from dados import (funcao do dos users)
### from validacao import (funcao de validacao) 
# --- apagar daqui ---
def carregar_usuarios():
    return [
        {"email": "professor@instituicao.com.br", "senha": "professor", "tipo": "professor", "nome": "Professor Teste"},
        {"email": "aluno@instituicao.com.br", "senha": "aluno", "tipo": "aluno", "nome": "Aluno Teste"}
    ]


def validar(email, senha, usuarios):
    return usuarios[0]

# --- apagar ate aq aqui(function de teste) ---

email = input()
senha = input()

usuarios = carregar_usuarios()
usuario = validar(email, senha, usuarios)

if usuario is None:
    print("erro")
else:
    tipo = usuario["tipo"]
    nome = usuario["nome"]
    print(tipo + ";" + nome)