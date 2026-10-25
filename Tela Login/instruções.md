Dividi o trabalho para que os três possam começar ao mesmo tempo, cada um no seu arquivo, sem um esperar o outro. Para isso funcionar, vocês combinam antes como as partes se encaixam. Esse combinado já vai pronto aqui embaixo, então não precisa discutir formato.

Como fica

login-eclusa (bash)                          login.py (python)
  lê e-mail e senha  ──── manda os dois ────▶  pega a lista no dados.py
                                               confere no validacao.py
  mostra o resultado ◀── devolve uma linha ──  imprime a resposta

tela1/
├── login-eclusa     a tela (já existe)
├── usuarios.json    Pessoa 1
├── dados.py         Pessoa 1
├── validacao.py     Pessoa 2
└── login.py         Pessoa 3 (e o final do login-eclusa)

O combinado

1. O formato do usuarios.json. Os campos são os da seção 5 do MVP, sem acento no nome do campo, e a senha fica em texto puro mesmo (no MVP é só teste):

[
  {"email": "professor@instituicao.com.br", "senha": "professor", "tipo": "professor", "nome": "Professor Teste"},
  {"email": "aluno@instituicao.com.br", "senha": "aluno", "tipo": "aluno", "nome": "Aluno Teste"}
]

2. As funções:

┌──────────────┬─────────────────────────────────┬──────────────────────────────┬───────────────────────────────────────────────────────┐
│   Arquivo    │             Função              │            Recebe            │                        Devolve                        │
├──────────────┼─────────────────────────────────┼──────────────────────────────┼───────────────────────────────────────────────────────┤
│ dados.py     │ carregar_usuarios()             │ nada                         │ a lista que está no usuarios.json                     │
├──────────────┼─────────────────────────────────┼──────────────────────────────┼──────────────────────────┤
│ validacao.py │ validar(email, senha, usuarios) │ o que foi digitado e a lista │ o dicionário do usuário, se bater; None, se não bater │
└──────────────┴─────────────────────────────────┴──────────────────────────────┴───────────────────────────────────────────────────────┘

3. A resposta do login.py para o bash (sempre uma linha só):
- se deu certo: professor;Professor Teste (tipo, ponto e vírgula, nome)
- se deu errado: erro

4. Duas regras que, se alguém quebrar, quebram tudo:
- Só o login.py usa print(), e só para imprimir a resposta. Qualquer outro print vai juntoentende. Por isso os testes ficam em arquivos separados (teste_dados.py,teste_validacao.py).
- No login.py, use input() vazio, e não input("E-mail: "). Quem mostra "E-mail:" é a tela; junto com a resposta.

Pessoa 1: Dados

Arquivos: usuarios.json e dados.py
O que vai aprender: o formato JSON, import json, open(), json.load() e try/except

1. Criar o usuarios.json exatamente igual ao do combinado.
2. No dados.py, escrever a carregar_usuarios(): ela abre o arquivo, lê com json.load() e d
3. Testar num teste_dados.py: importar a função, imprimir o que ela devolve e ver se aparecem os dois usuários.
4. Se o usuarios.json não existir ou estiver quebrado (faltando uma vírgula, por exemplo),vez de travar. Isso se faz com try/except; peça ajuda se empacar aqui.

Está pronto quando: o teste_dados.py mostra os dois usuários, e apagar o JSON não dá erro.

Essa parte termina primeiro, então a Pessoa 1 também fica responsável por rodar o teste final.

Pessoa 2: Validação

Arquivo: validacao.py
O que vai aprender: lista de dicionários, for, if, return, .strip() e .lower()

1. Escrever a validar(email, senha, usuarios): ela passa por cada usuário da lista e, se ovolve esse usuário. Se chegar ao fim sem achar ninguém, devolve None.
2. Antes de comparar, limpar o e-mail: tirar os espaços das pontas e passar para minúsculo. Assim, " Aluno@Instituicao.com.br" também funciona. A senha não passa por essa limpeza: ela precisa bater exatamente.
3. Não precisa esperar o JSON ficar pronto. No teste_validacao.py, escreva a lista na mão este estes casos:
   - professor certo → devolve o professor
   - aluno certo → devolve o aluno
   - senha errada → None
   - e-mail que não existe → None
   - os dois campos vazios → None
   - e-mail com maiúscula e espaço → devolve o usuário

Está pronto quando: os 6 casos dão o resultado esperado.

Pessoa 3: Ligação com a tela

Arquivos: login.py e o final do login-eclusa
O que vai aprender: input(), print(), importar uma função de outro arquivo e juntar textos

1. No login.py: ler o e-mail com input(), ler a senha com input(), carregar os usuários, vno formato do combinado.
2. Para não esperar ninguém, comece com duas funções de mentira no topo do login.py: uma carregar_usuarios() que devolve a lista escrita na mão e uma validar() que sempre devolve o primeiro usuário. Quando as partes 1 e 2 ficarem prontas, apague essas duas e troque por from dados import carregar_usuarios e from validacao import validar.
3. Testar sem a tela, direto no terminal:
printf 'professor@instituicao.com.br\nprofessor\n' | python3 login.py
   Tem que aparecer professor;Professor Teste.
4. No login-eclusa, logo depois de senha=$CAMPO, mandar os dois para o Python e guardar a
resposta=$(printf '%s\n%s\n' "$email" "$senha" | python3 "$(dirname "$0")/login.py")
   - Se a resposta for erro (ou vier vazia): chamar desenhar_caixa de novo, que já limpa oenha errados. Tenta de novo. embaixo da caixa e pedir tudo de novo.
   - Se não for: separar com IFS=';' read -r tipo nome <<< "$resposta" e mostrar Oi, $nome!. Os menus ainda não existem, então depois do "Oi" o programa só termina.

Está pronto quando: o teste final passa usando a tela.

Ordem

1. Os três juntos, uns 20 minutos: ler o combinado e criar os arquivos vazios.
2. Cada um faz a sua parte, ao mesmo tempo.
3. Juntar: a Pessoa 3 troca as funções de mentira pelos imports de verdade.
4. Teste final (a Pessoa 1 roda e os três acompanham):
   - [ ] professor certo → Oi, Professor Teste!
   - [ ] aluno certo → Oi, Aluno Teste!
   - [ ] senha errada → aparece o aviso e a tela pede de novo, sem travar
   - [ ] e-mail que não existe → o mesmo aviso
   - [ ] só Enter nos dois campos → o mesmo aviso
   - [ ] usuarios.json apagado → nenhum erro do Python aparece na tela
