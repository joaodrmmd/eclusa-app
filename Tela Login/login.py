from dados import (carregar_usuarios)
from validacao import (validar) 

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