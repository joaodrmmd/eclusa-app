# Tela do professor: divisão do trabalho

A tela (`tela-professor.sh`) já está pronta. Ela mostra os menus, faz as perguntas e, sempre que precisa de dados, chama o `professor.py`. A parte de vocês é fazer o Python responder do jeito combinado aqui embaixo.

É o mesmo esquema do login: cada um no seu arquivo, os três começando ao mesmo tempo, sem um esperar o outro.

## Como fica

```
tela-professor.sh (bash)                       professor.py (python)
  mostra os menus e pergunta  ─── manda ───▶     usa o dados.py  (tarefas.json e interacoes.json)
  mostra o resultado          ◀── responde ──    usa o skill.py  (cria e apaga a skill)
```

```
Tela Professor/
├── tela-professor.sh   a tela (pronta)
├── tarefas.json        Pessoa 1
├── interacoes.json     Pessoa 1 (de teste, escrito na mão)
├── dados.py            Pessoa 1
├── molde-skill.md      Pessoa 2
├── skill.py            Pessoa 2
└── professor.py        Pessoa 3
```

Pra abrir a tela: `./tela-professor.sh`. Ela sempre roda de dentro da própria pasta, então no Python dá pra abrir os arquivos só pelo nome (`open("tarefas.json")`).

---

## O combinado

### 1. Como a tela conversa com o professor.py

Igual ao login: a tela manda as informações pelo `input()` e lê o que o `professor.py` imprime com `print()`.

A diferença é que agora a tela pede várias coisas diferentes. Por isso, **a primeira linha sempre diz o que a tela quer** (é o "comando"). Depois vêm as informações, **uma por linha**. A resposta também volta **uma informação por linha**.

| Comando | A tela manda (uma por linha) | O professor.py responde (uma por linha) |
| --- | --- | --- |
| `listar` | só `listar` | 5 linhas pra cada tarefa: número, título, IA, modelo, status. Se não tiver nenhuma tarefa, não imprime nada |
| `adicionar` | `adicionar`, título, descrição, as linhas das instruções, `FIM`, IA, modelo | o número da tarefa nova |
| `mostrar` | `mostrar`, número | 5 linhas: título, descrição, IA, modelo, status |
| `editar` | `editar`, número, título, descrição, as linhas das instruções, `FIM`, IA, modelo | `ok` |
| `alternar` | `alternar`, número | o status novo: `aberta` ou `encerrada` |
| `apagar` | `apagar`, número | `ok` |
| `resultados` | `resultados`, número | o total de perguntas, o total de alunos e, pra cada interação, 3 linhas: aluno, pergunta, resposta |

Se o número não for de nenhuma tarefa, todos os comandos que recebem número respondem só `erro`.

**Exemplo:** pra criar a tarefa "Recursão", a tela manda isto:

```
adicionar
Recursão
Fazer a função de fatorial
Não dá o código pronto.
Faz perguntas pro aluno pensar.
FIM
claude
haiku
```

E espera receber de volta só isto (se for a primeira tarefa):

```
1
```

**Detalhes:**

- O número sempre chega só com dígitos (a própria tela já reclama se a pessoa digitar letra). Pode usar `int(input())` sem medo.
- A IA chega em minúsculo: `claude` ou `codex`. O modelo chega do jeito que está na lista da tela (`haiku`, `sonnet`, `opus`...).
- No `editar`, a tela manda **tudo de novo**. Se o professor apertou Enter pra manter o título, ela manda o título antigo. A única exceção são as instruções: se vier `FIM` logo de cara, sem nenhuma linha antes, é porque o professor não quis reescrever, e as instruções antigas continuam.
- As listas de modelos ficam no começo do `tela-professor.sh`. As do Claude são as do MVP. As do Codex eu peguei da lista do Codex instalado no computador: troquem se quiserem outras.

### 2. O formato do tarefas.json

O arquivo começa assim:

```json
{
  "proximo_numero": 1,
  "tarefas": []
}
```

Cada tarefa que entra na lista fica assim (os campos são os da seção 5 do MVP, sem acento no nome do campo):

```json
{
  "numero": 3,
  "titulo": "Recursão",
  "descricao": "Fazer a função de fatorial",
  "instrucoes": ["Não dá o código pronto.", "Faz perguntas pro aluno pensar."],
  "ia": "claude",
  "modelo": "haiku",
  "skill": "tarefa-3",
  "status": "aberta"
}
```

**Por que guardar o `proximo_numero`?** O MVP diz que o número da tarefa nunca repete. Se a gente usasse "o maior número + 1", era só apagar a tarefa 3 e criar outra que nascia uma tarefa 3 nova. Guardando o próximo número no arquivo, isso não acontece.

As instruções ficam numa lista, uma linha em cada item, porque é assim que elas chegam da tela.

### 3. O formato do interacoes.json

Quem vai criar as interações de verdade é a tela do aluno, que ainda não existe. Por enquanto, a Pessoa 1 escreve esse arquivo na mão, só pra dar pra testar o "Ver resultados":

```json
[
  {"numero": 1, "tarefa": 1, "aluno": "aluno@instituicao.com.br", "pergunta": "por onde eu começo?", "resposta": "que tal começar pelo caso em que o número é 0?"},
  {"numero": 2, "tarefa": 1, "aluno": "aluno@instituicao.com.br", "pergunta": "me dá o código pronto?", "resposta": "pronto eu não posso dar, mas pensa assim: ..."}
]
```

### 4. As funções

| Arquivo | Função | Recebe | Devolve |
| --- | --- | --- | --- |
| `dados.py` | `carregar_tarefas()` | nada | o dicionário do `tarefas.json` (a gente chama ele de `banco`) |
| `dados.py` | `salvar_tarefas(banco)` | o banco | nada (grava no `tarefas.json`) |
| `dados.py` | `buscar_tarefa(banco, numero)` | o banco e um número | a tarefa com esse número, ou `None` |
| `dados.py` | `carregar_interacoes()` | nada | a lista do `interacoes.json` |
| `dados.py` | `interacoes_da_tarefa(interacoes, numero)` | a lista e um número | uma lista só com as interações dessa tarefa |
| `dados.py` | `contar_alunos(interacoes)` | uma lista de interações | quantos alunos diferentes aparecem nela |
| `skill.py` | `pasta_da_skill(tarefa)` | uma tarefa | o caminho da pasta da skill dela |
| `skill.py` | `gerar_skill(tarefa)` | uma tarefa | nada (cria a pasta e o `SKILL.md`) |
| `skill.py` | `apagar_skill(tarefa)` | uma tarefa | nada (apaga o `SKILL.md` e a pasta) |

### 5. Regras que, se alguém quebrar, quebram tudo

- **Só o `professor.py` usa `print()`**, e só pra imprimir a resposta. Qualquer outro print vai junto com a resposta e a tela se perde. Os testes ficam em arquivos separados (`teste_dados.py`, `teste_skill.py`). No login isso já aconteceu: o `dados.py` de lá tem `print()` dentro do `except`.
- **`input()` vazio**, nunca `input("Título: ")`. Quem mostra o "Título:" é a tela.
- **Todo `open()` com `encoding="utf-8"`**, senão os acentos quebram. No `json.dump`, usem `indent=2` e `ensure_ascii=False`: o arquivo fica organizado e com acento normal, dá pra abrir e conferir.
- **A resposta da IA pode ter quebra de linha.** No `resultados`, antes de imprimir, troca `"\n"` por `" "`, senão uma resposta vira duas linhas e a tela embaralha tudo.
- **O `skill.py` só mexe na pasta `tarefa-N`** dentro de `~/.claude/skills` ou de `~/.codex/skills`. Nada de apagar pasta com tudo dentro (`shutil.rmtree`): usem `os.remove` no arquivo e depois `os.rmdir` na pasta vazia. Assim, se alguém errar o caminho, o pior que acontece é dar erro, e não apagar coisa dos outros.

---

## Pessoa 1: Dados

**Arquivos:** `tarefas.json`, `interacoes.json` e `dados.py`
**O que vai aprender:** `json.load` e `json.dump`, dicionário com lista dentro, `for`, `if`, `len()`

1. Criar o `tarefas.json` do jeito que ele começa (item 2 do combinado) e o `interacoes.json` com as duas interações de teste (item 3).
2. No `dados.py`, escrever as funções:
   - `carregar_tarefas()`: abre o `tarefas.json` e devolve o dicionário. Se o arquivo não existir, devolve `{"proximo_numero": 1, "tarefas": []}`, igualzinho a um arquivo novo.
   - `salvar_tarefas(banco)`: abre o `tarefas.json` pra escrita (`"w"`) e grava o banco com `json.dump`.
   - `buscar_tarefa(banco, numero)`: passa por cada tarefa de `banco["tarefas"]`; se o `"numero"` for igual, devolve a tarefa. Se chegar ao fim sem achar, devolve `None`.
   - `carregar_interacoes()`: abre o `interacoes.json` e devolve a lista. Se o arquivo não existir, devolve `[]`.
   - `interacoes_da_tarefa(interacoes, numero)`: cria uma lista vazia, passa por cada interação e coloca na lista nova só as que têm `"tarefa"` igual ao número.
   - `contar_alunos(interacoes)`: cria uma lista vazia de alunos já vistos; pra cada interação, se o aluno ainda não está na lista, coloca ele lá. No fim, devolve o tamanho da lista.
3. Testar num `teste_dados.py`:
   - `carregar_tarefas()` com o arquivo novo → mostra o banco vazio
   - colocar uma tarefa na mão em `banco["tarefas"]`, `salvar_tarefas(banco)`, carregar de novo → a tarefa está lá (e dá pra ver ela no `tarefas.json`)
   - `buscar_tarefa(banco, 1)` → a tarefa; `buscar_tarefa(banco, 99)` → `None`
   - `interacoes_da_tarefa(carregar_interacoes(), 1)` → as 2 interações; com o número 99 → `[]`
   - `contar_alunos` das 2 interações de teste → `1`
   - apagar o `tarefas.json` e chamar `carregar_tarefas()` → não dá erro

**Está pronto quando:** todos os testes acima dão o resultado esperado.

Essa parte deve terminar primeiro, então a Pessoa 1 também fica responsável por rodar o teste final.

---

## Pessoa 2: Skill

**Arquivos:** `molde-skill.md` e `skill.py`
**O que vai aprender:** caminhos de arquivo com `os`, criar e apagar pasta, escrever arquivo, `.replace()` e `"\n".join()`

**O que é a skill:** um arquivo chamado `SKILL.md`, dentro de uma pasta com o nome da skill. O Claude Code procura skills em `~/.claude/skills/` e o Codex em `~/.codex/skills/`. Então a skill da tarefa 3 de Claude fica em `~/.claude/skills/tarefa-3/SKILL.md`.

1. Escrever o `molde-skill.md`. É o texto que vale pra toda tarefa, com marcadores entre chaves no lugar das informações de cada uma:

   ```markdown
   ---
   name: {skill}
   description: Regras da tarefa {numero} do ECLUSA. Use sempre que o aluno pedir ajuda com esta tarefa.
   ---

   # Tarefa {numero}: {titulo}

   {descricao}

   ## Regras que valem sempre

   (escrevam aqui as regras fixas; as ideias estão na seção 7 do MVP)

   ## Instruções do professor

   {instrucoes}
   ```

   O pedaço entre os `---` é o cabeçalho da skill, e tem que ter `name` e `description`. **Não coloquem o `{titulo}` no cabeçalho**: um título com aspas ou dois-pontos quebra o cabeçalho, e o MVP tem um teste exatamente com aspas no título.

2. No `skill.py`, escrever as funções:
   - `pasta_da_skill(tarefa)`: se a IA da tarefa for `claude`, a pasta base é `os.path.expanduser("~/.claude/skills")`; se for `codex`, é `os.path.expanduser("~/.codex/skills")`. Devolve `os.path.join(base, tarefa["skill"])`.
   - `gerar_skill(tarefa)`: lê o `molde-skill.md` inteiro, troca cada marcador com `.replace()` (`"{titulo}"` pelo título e assim por diante; o `{instrucoes}` vira `"\n".join(tarefa["instrucoes"])`), cria a pasta com `os.makedirs(pasta, exist_ok=True)` e escreve o texto num `SKILL.md` dentro dela.
   - `apagar_skill(tarefa)`: se o `SKILL.md` existir (`os.path.exists`), apaga com `os.remove`; depois, se a pasta existir, apaga com `os.rmdir`. Se nada existir, não faz nada e não dá erro.
3. Testar num `teste_skill.py` com uma tarefa escrita na mão, de número 99 (pra não bagunçar as de verdade), com acento e aspas no título, tipo `'Listas "básicas" e acentuação'`:
   - `gerar_skill` → abre `~/.claude/skills/tarefa-99/SKILL.md` e confere se o texto ficou certo
   - `apagar_skill`, troca a IA da tarefa pra `codex`, `gerar_skill` → a pasta sumiu do `.claude` e apareceu no `.codex`
   - `apagar_skill` → sumiu de lá também
   - `apagar_skill` de novo → não dá erro

**Está pronto quando:** os testes passam e não sobra nenhuma `tarefa-99` em nenhuma das duas pastas.

---

## Pessoa 3: professor.py

**Arquivo:** `professor.py`
**O que vai aprender:** `input()` dentro de um `while`, `if`/`elif`, `int()` e `str()`, usar funções de outros arquivos

1. A estrutura é um `if`/`elif` em cima da primeira linha:

   ```python
   comando = input()

   if comando == "listar":
       ...
   elif comando == "adicionar":
       ...
   ```

2. Pra ler as instruções (vale pro `adicionar` e pro `editar`):

   ```python
   instrucoes = []
   linha = input()
   while linha != "FIM":
       instrucoes.append(linha)
       linha = input()
   ```

3. Em todo comando, **primeiro lê tudo que a tela mandou, depois faz o resto.** O que cada um faz:
   - **listar:** carrega o banco e, pra cada tarefa, imprime número, título, IA, modelo e status (um `print` pra cada).
   - **adicionar:** lê tudo. Pega o número em `banco["proximo_numero"]` e soma 1 lá. Monta o dicionário da tarefa com `"skill": "tarefa-" + str(numero)` e `"status": "aberta"`, coloca na lista, salva, chama `gerar_skill(tarefa)` e imprime o número.
   - **mostrar:** busca a tarefa. Se for `None`, imprime `erro`; se não, imprime título, descrição, IA, modelo e status.
   - **editar:** lê tudo e busca a tarefa (`None` → `erro`). **Chama `apagar_skill(tarefa)` antes de mudar qualquer coisa**: se a IA mudar de Claude pra Codex, a skill velha precisa sair da pasta do Claude, e só a tarefa antiga sabe onde ela está. Depois troca título, descrição, IA e modelo; se a lista de instruções não estiver vazia, troca as instruções também. Salva, chama `gerar_skill(tarefa)` e imprime `ok`.
   - **alternar:** busca a tarefa (`None` → `erro`). Se está `aberta`, vira `encerrada`; se não, vira `aberta`. Salva e imprime o status novo.
   - **apagar:** busca a tarefa (`None` → `erro`). Chama `apagar_skill(tarefa)`, tira a tarefa da lista com `banco["tarefas"].remove(tarefa)`, salva e imprime `ok`. As interações dessa tarefa continuam no `interacoes.json` (o MVP ainda não decidiu se apaga ou esconde) e, como o número nunca repete, elas não se misturam com tarefa nova.
   - **resultados:** busca a tarefa (`None` → `erro`). Pega as interações dela com `interacoes_da_tarefa`, imprime quantas são (`len`), imprime `contar_alunos(...)` e, pra cada interação, imprime aluno, pergunta e resposta (com o `"\n"` trocado por `" "`).
4. Pra não esperar ninguém, comece com funções de mentira no topo do `professor.py`:
   - `carregar_tarefas()` devolve um banco escrito na mão, com uma tarefa
   - `salvar_tarefas(banco)`, `gerar_skill(tarefa)` e `apagar_skill(tarefa)` não fazem nada (só `pass`)
   - `buscar_tarefa(banco, numero)` devolve sempre a primeira tarefa
   - `carregar_interacoes()` devolve a lista do item 3 do combinado, `interacoes_da_tarefa` devolve a lista que recebeu e `contar_alunos` devolve `1`

   Quando as partes 1 e 2 ficarem prontas, apague as de mentira e coloque no lugar:

   ```python
   from dados import carregar_tarefas, salvar_tarefas, buscar_tarefa, carregar_interacoes, interacoes_da_tarefa, contar_alunos
   from skill import gerar_skill, apagar_skill
   ```

5. Testar sem a tela, direto no terminal:

   ```bash
   printf 'listar\n' | python3 professor.py
   printf 'adicionar\nRecursão\nFazer a função de fatorial\nNão dá o código pronto.\nFIM\nclaude\nhaiku\n' | python3 professor.py
   printf 'mostrar\n1\n' | python3 professor.py
   printf 'resultados\n1\n' | python3 professor.py
   ```

   Cada um tem que responder exatamente como está na tabela do combinado.

**Está pronto quando:** os testes do terminal dão as respostas certas e, depois de juntar, o teste final passa usando a tela.

---

## Ordem

1. **Os três juntos, uns 20 minutos:** ler o combinado e criar os arquivos vazios.
2. **Cada um faz a sua parte**, ao mesmo tempo.
3. **Juntar:** a Pessoa 3 troca as funções de mentira pelos imports de verdade.
4. **Teste final pela tela** (a Pessoa 1 roda e os três acompanham). Esses testes são os da seção 11 do MVP que tocam no professor:
   - [ ] criar tarefa → aparece no "Gerenciar tarefas" e a skill aparece em `~/.claude/skills/tarefa-1/SKILL.md`
   - [ ] criar tarefa com acento e aspas no título → a skill é criada do mesmo jeito
   - [ ] editar as instruções → o `SKILL.md` muda
   - [ ] trocar de Claude pra Codex na edição → a pasta sai de `~/.claude/skills` e vai pra `~/.codex/skills`
   - [ ] encerrar tarefa → o status vira `encerrada` (sumir da lista do aluno fica pra tela do aluno)
   - [ ] apagar tarefa → some da tabela e a pasta da skill some
   - [ ] apagar a última tarefa e criar outra → a nova ganha um número novo, não repete
   - [ ] número que não existe → "Não achei nenhuma tarefa com esse número."
   - [ ] letra onde era pra ser número → "Digita só o número, por favor."
   - [ ] ver resultados da tarefa 1, com o `interacoes.json` de teste → "2 perguntas de 1 aluno" e as duas perguntas embaixo
