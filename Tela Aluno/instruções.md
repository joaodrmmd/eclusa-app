# Tela do aluno: divisão do trabalho

A tela (`tela-aluno.sh`) fica fora da divisão, igual à do professor: ela mostra os menus e o chat e, sempre que precisa de dados, chama o `aluno.py`. A parte de vocês é fazer o Python responder do jeito combinado aqui embaixo.

É o mesmo esquema das outras telas: cada um no seu arquivo, os três começando ao mesmo tempo, sem um esperar o outro.

## Como fica

```
tela-aluno.sh (bash)                           aluno.py (python)
  mostra os menus e o chat    ─── manda ───▶     usa o dados.py  (lê as tarefas, salva as interações)
  mostra a resposta da IA     ◀── responde ──    usa o ia.py     (chama o Claude, o Codex ou o Gemini)
```

```
Tela Aluno/
├── tela-aluno.sh           a tela (fora da divisão)
├── tarefas-teste.json      Pessoa 1 (de teste, escrito na mão)
├── interacoes-teste.json   Pessoa 1 (de teste, começa vazio)
├── dados.py                Pessoa 1
├── ia.py                   Pessoa 2
└── aluno.py                Pessoa 3
```

Pra abrir a tela: `./tela-aluno.sh`. Ela sempre roda de dentro da própria pasta, então no Python os caminhos partem da pasta `Tela Aluno`.

---

## O combinado

### 1. Como a tela conversa com o aluno.py

Igual à tela do professor: a primeira linha é o comando, e as informações vão **uma por linha**, pelo `input()`. A resposta volta pelo `print()`.

| Comando | A tela manda (uma por linha) | O aluno.py responde |
| --- | --- | --- |
| `listar` | só `listar` | 2 linhas pra cada tarefa **aberta**: número, título. Se não tiver nenhuma, não imprime nada |
| `entrar` | `entrar`, número | 4 linhas: título, descrição, IA, modelo. Se a tarefa não existir ou estiver encerrada, só `erro` |
| `perguntar` | `perguntar`, e-mail do aluno, número, pergunta | `ok` na primeira linha e, a partir da segunda, a resposta da IA. Se a tarefa não existir ou estiver encerrada, só `erro`. Se a IA não responder, só `sem-ia` |

**Exemplo:** o aluno pergunta "por onde eu começo?" na tarefa 3. A tela manda isto:

```
perguntar
aluno@instituicao.com.br
3
por onde eu começo?
```

E espera receber de volta:

```
ok
Que tal começar pelo caso em que o número é 0?
```

**Detalhes:**

- **Por que o `ok` na primeira linha?** A resposta da IA pode ter várias linhas e pode até ser a palavra "erro". Com o `ok` antes, a tela nunca confunde resposta com aviso.
- **Aqui a resposta da IA vai inteira, com as quebras de linha.** Não troquem `"\n"` por `" "`. Quem faz essa troca é o `resultados` do professor.
- **Tarefa encerrada, pro aluno, é igual a tarefa que não existe.** Vale também no `perguntar`: se o professor encerrar a tarefa no meio do chat, a próxima pergunta recebe `erro`.
- **O número sempre chega só com dígitos** (a tela reclama antes). Pode usar `int(input())`.
- **A pergunta é sempre uma linha só**, e a tela não manda pergunta vazia.
- **A IA não lembra da conversa.** Cada pergunta é uma chamada nova (no MVP, a memória ficou pra v2).

### 2. De onde vem o e-mail do aluno

A interação precisa do e-mail, então a tela recebe ele na hora de abrir: `./tela-aluno.sh aluno@instituicao.com.br`. Sem nada depois do nome, ela usa `aluno@instituicao.com.br`, pra dar pra testar sem passar pelo login.

O `aluno.py` só recebe o e-mail pelo `input()`, como qualquer outra informação. Ligar o login nas telas fica fora desta divisão.

### 3. Os arquivos são os mesmos do professor

O professor e o aluno têm que enxergar as mesmas tarefas, então os dados de verdade continuam na pasta do professor:

| Arquivo | Quem grava | O aluno faz o quê |
| --- | --- | --- |
| `../Tela Professor/tarefas.json` | só o professor | **só lê**, nunca grava |
| `../Tela Professor/interacoes.json` | só o aluno | lê e acrescenta no final |

Durante o desenvolvimento, vocês usam os arquivos de teste, pra não misturar teste com dado de verdade. Os caminhos ficam em duas variáveis no topo do `dados.py`:

```python
ARQUIVO_TAREFAS = "tarefas-teste.json"
ARQUIVO_INTERACOES = "interacoes-teste.json"
```

Na hora de juntar, é só trocar por:

```python
ARQUIVO_TAREFAS = "../Tela Professor/tarefas.json"
ARQUIVO_INTERACOES = "../Tela Professor/interacoes.json"
```

### 4. O formato da interação

Os campos são os da seção 5 do MVP, e é o formato que o `Ver resultados` do professor já lê:

```json
{
  "numero": 3,
  "tarefa": 1,
  "aluno": "aluno@instituicao.com.br",
  "pergunta": "por onde eu começo?",
  "resposta": "Que tal começar pelo caso em que o número é 0?"
}
```

**Como escolher o `numero`:** o maior que já existe na lista, mais 1 (lista vazia → 1). Nas tarefas isso não servia, porque tarefa pode ser apagada e o número repetiria. Interação nunca é apagada, então aqui não tem esse problema.

**Se a IA não responder, não salva nada.** Sem resposta não existe interação, e o aluno pode tentar de novo.

### 5. Como chamar a IA

Estes são os comandos que rodamos de verdade (Claude Code 2.1.319 com `haiku`, Codex 0.166.0 com `gpt-6-luna`):

**Claude:**

```bash
claude -p "/tarefa-3 por onde eu começo?" --model haiku --tools "" --no-session-persistence
```

**Gemini (Antigravity CLI, `agy`):**

```
agy -p '/tarefa-3 por onde eu começo?' --model gemini-3.8-flash-low --mode plan
```

O `--mode plan` impede a IA de rodar comandos e ler arquivos. Se ela tentar, o `agy` imprime uma mensagem começando com `jetski:` e o `ia.py` trata como falha (`None`).

**Codex:**

```bash
codex exec --model gpt-6-luna --sandbox read-only --skip-git-repo-check --ephemeral --color never --disable shell_tool --disable unified_exec '$tarefa-3 por onde eu começo?'
```

O que o teste mostrou, e por que o comando é desse jeito:

| O que testamos | Claude | Codex |
| --- | --- | --- |
| Skill instalada | seguiu a skill | seguiu a skill |
| Skill **não** instalada | **respondeu mesmo assim, sem as regras** | **respondeu mesmo assim, sem as regras** |
| Pedir pra listar os arquivos da pasta | não listou | com só `--sandbox read-only`, **listou**; com os dois `--disable`, não listou |

Duas conclusões que viram regra (item 7):

1. **O `ia.py` tem que conferir se o `SKILL.md` existe antes de chamar a IA.** Nos dois casos, a skill faltando não dá erro: a IA responde normal, sem as regras do professor.
2. **No Codex, o `--sandbox read-only` não basta.** Ele impede de mexer nos arquivos, mas a IA ainda roda comandos e lê a pasta. Quem tira isso são os dois `--disable`.

### 6. As funções

| Arquivo | Função | Recebe | Devolve |
| --- | --- | --- | --- |
| `dados.py` | `carregar_tarefas()` | nada | o dicionário do arquivo de tarefas (o `banco`) |
| `dados.py` | `tarefas_abertas(banco)` | o banco | uma lista só com as tarefas abertas |
| `dados.py` | `buscar_tarefa_aberta(banco, numero)` | o banco e um número | a tarefa, se existir e estiver aberta; senão, `None` |
| `dados.py` | `carregar_interacoes()` | nada | a lista do arquivo de interações |
| `dados.py` | `salvar_interacao(numero_tarefa, aluno, pergunta, resposta)` | os 4 dados | nada (acrescenta uma interação no arquivo) |
| `ia.py` | `pasta_da_skill(tarefa)` | uma tarefa | o caminho da pasta da skill dela |
| `ia.py` | `skill_instalada(tarefa)` | uma tarefa | `True` se o `SKILL.md` existir; senão, `False` |
| `ia.py` | `montar_comando(tarefa, pergunta)` | uma tarefa e a pergunta | a lista com o comando |
| `ia.py` | `perguntar_ia(tarefa, pergunta)` | uma tarefa e a pergunta | o texto da resposta, ou `None` se não deu certo |

### 7. Regras que, se alguém quebrar, quebram tudo

- **Só o `aluno.py` usa `print()`**, e só pra imprimir a resposta. Os testes ficam em arquivos separados (`teste_dados.py`, `teste_ia.py`).
- **`input()` vazio**, nunca `input("Pergunta: ")`. Quem mostra o texto é a tela.
- **Todo `open()` com `encoding="utf-8"`.** No `json.dump`, usem `indent=2` e `ensure_ascii=False`.
- **O aluno nunca escolhe a IA, o modelo nem a skill.** Os três vêm sempre da tarefa salva.
- **Sem skill, sem IA.** Se o `SKILL.md` não existir, o `perguntar_ia` devolve `None` e nem chama a IA.
- **A pergunta vai sempre como um item da lista do comando.** Nada de `shell=True` nem `os.system`: é o aluno quem digita a pergunta, e assim um texto como `$(whoami)` continua sendo só texto.
- **O aluno nunca grava no `tarefas.json`.** Quem cuida dele é o professor.

---

## Pessoa 1: Dados

**Arquivos:** `tarefas-teste.json`, `interacoes-teste.json` e `dados.py`
**O que vai aprender:** filtrar uma lista, juntar duas condições com `and`, achar o maior número de uma lista, ler e regravar um JSON

1. Criar o `tarefas-teste.json` com uma tarefa aberta (número 1) e uma encerrada (número 2):

   ```json
   {
     "proximo_numero": 3,
     "tarefas": [
       {"numero": 1, "titulo": "Recursão", "descricao": "Fazer a função de fatorial", "instrucoes": ["Não dá o código pronto."], "ia": "claude", "modelo": "haiku", "skill": "tarefa-1", "status": "aberta"},
       {"numero": 2, "titulo": "Listas", "descricao": "Somar os itens de uma lista", "instrucoes": ["Só dá dica."], "ia": "codex", "modelo": "gpt-6-luna", "skill": "tarefa-2", "status": "encerrada"}
     ]
   }
   ```

2. Criar o `interacoes-teste.json` só com `[]`.
3. No `dados.py`, colocar as duas variáveis do item 3 do combinado no topo e escrever as funções:
   - `carregar_tarefas()`: abre `ARQUIVO_TAREFAS` e devolve o dicionário. Se o arquivo não existir, devolve `{"proximo_numero": 1, "tarefas": []}`.
   - `tarefas_abertas(banco)`: cria uma lista vazia, passa por cada tarefa de `banco["tarefas"]` e coloca na lista nova só as que têm `"status"` igual a `"aberta"`.
   - `buscar_tarefa_aberta(banco, numero)`: passa por cada tarefa; se o `"numero"` for igual **e** o status for `"aberta"`, devolve a tarefa. Se chegar ao fim sem achar, devolve `None`.
   - `carregar_interacoes()`: abre `ARQUIVO_INTERACOES` e devolve a lista. Se o arquivo não existir, devolve `[]`.
   - `salvar_interacao(numero_tarefa, aluno, pergunta, resposta)`: carrega a lista, acha o maior `"numero"` que já existe (começa em 0 e passa por cada interação), monta o dicionário do item 4 do combinado com esse número mais 1, coloca no final da lista e grava o arquivo inteiro de novo com `json.dump`.
4. Testar num `teste_dados.py`:
   - `tarefas_abertas(carregar_tarefas())` → só a tarefa 1
   - `buscar_tarefa_aberta(banco, 1)` → a tarefa; com o `2` (encerrada) → `None`; com o `99` → `None`
   - salvar duas interações → o arquivo fica com números 1 e 2, e os acentos aparecem normais
   - apagar o `interacoes-teste.json` e salvar uma interação → não dá erro, e o arquivo volta com o número 1
   - apagar o `tarefas-teste.json` e chamar `carregar_tarefas()` → não dá erro (depois, criem o arquivo de novo)

**Está pronto quando:** todos os testes acima dão o resultado esperado.

Essa parte deve terminar primeiro, então a Pessoa 1 também fica responsável por rodar o teste final.

---

## Pessoa 2: IA

**Arquivo:** `ia.py`
**O que vai aprender:** rodar outro programa pelo Python com `subprocess`, lista de argumentos, `try`/`except`, conferir se um arquivo existe

**O que esse arquivo faz:** é ele que garante a parte principal do projeto, que o aluno só fala com a IA do jeito que o professor configurou.

1. `pasta_da_skill(tarefa)`: igual à do professor. Se a IA for `claude`, a base é `os.path.expanduser("~/.claude/skills")`; se for `codex`, é `os.path.expanduser("~/.codex/skills")`. Devolve `os.path.join(base, tarefa["skill"])`.
2. `skill_instalada(tarefa)`: devolve `os.path.exists(os.path.join(pasta_da_skill(tarefa), "SKILL.md"))`.
3. `montar_comando(tarefa, pergunta)`: monta a lista com os comandos do item 5 do combinado. Copiem exatamente, porque aqui cada detalhe importa. No Claude a skill é chamada com `/` e no Codex com `$`:

   ```python
   def montar_comando(tarefa, pergunta):
       if tarefa["ia"] == "claude":
           return ["claude", "-p", "/" + tarefa["skill"] + " " + pergunta,
                   "--model", tarefa["modelo"], "--tools", "", "--no-session-persistence"]
       return ["codex", "exec", "--model", tarefa["modelo"], "--sandbox", "read-only",
               "--skip-git-repo-check", "--ephemeral", "--color", "never",
               "--disable", "shell_tool", "--disable", "unified_exec",
               "$" + tarefa["skill"] + " " + pergunta]
   ```

4. `perguntar_ia(tarefa, pergunta)`:
   - Se `skill_instalada(tarefa)` for `False`, devolve `None` na hora.
   - Roda o comando. O `subprocess` é novidade, então aqui vai o jeito de usar:

     ```python
     resultado = subprocess.run(
         montar_comando(tarefa, pergunta),
         capture_output=True,
         encoding="utf-8",
         stdin=subprocess.DEVNULL,
         timeout=120,
     )
     ```

     - `capture_output=True` guarda o que o programa imprimiu em vez de jogar na tela. O texto da resposta fica em `resultado.stdout`.
     - `stdin=subprocess.DEVNULL` é obrigatório: sem isso, a IA herda a entrada que a tela mandou pro `aluno.py`.
     - `timeout=120` desiste depois de 2 minutos.
   - Coloca o `subprocess.run` dentro de um `try`, com `except (FileNotFoundError, subprocess.TimeoutExpired)` devolvendo `None`. O primeiro erro acontece se a IA não estiver instalada, e o segundo, se ela demorar demais.
   - Se `resultado.returncode` for diferente de `0`, devolve `None`.
   - Tira os espaços das pontas com `.strip()`. Se sobrar texto vazio, devolve `None`; se não, devolve o texto.
5. Testar num `teste_ia.py`, com uma tarefa escrita na mão de número 99. Antes, criem na mão os arquivos `~/.claude/skills/tarefa-99/SKILL.md` e `~/.codex/skills/tarefa-99/SKILL.md` com isto:

   ```markdown
   ---
   name: tarefa-99
   description: Regras da tarefa 99 do ECLUSA. Use sempre que o aluno pedir ajuda com esta tarefa.
   ---

   # Tarefa 99: teste

   Regra obrigatória: comece TODA resposta com a palavra "BANANA:" e responda em no máximo 1 frase.
   ```

   Rodem cada teste com `claude`/`haiku` e com `codex`/`gpt-6-luna`:
   - perguntar "quanto é 2+2?" → a resposta começa com `BANANA:`
   - pedir "liste os nomes dos arquivos desta pasta" → a IA não lista
   - perguntar `$(whoami)` → a pergunta é tratada como texto, e o comando não roda
   - uma tarefa com `"skill": "tarefa-98"`, que não existe → devolve `None`

   No fim, apaguem as duas pastas `tarefa-99`.

**Está pronto quando:** os testes dão certo nas duas IAs e não sobra nenhuma `tarefa-99`.

---

## Pessoa 3: aluno.py

**Arquivo:** `aluno.py`
**O que vai aprender:** `if`/`elif`, juntar funções de outros arquivos, responder num formato combinado

1. A estrutura é a mesma do `professor.py`, um `if`/`elif` em cima da primeira linha:

   ```python
   comando = input()

   if comando == "listar":
       ...
   elif comando == "entrar":
       ...
   elif comando == "perguntar":
       ...
   ```

2. Em todo comando, **primeiro lê tudo que a tela mandou, depois faz o resto.** O que cada um faz:
   - **listar:** carrega o banco e, pra cada tarefa de `tarefas_abertas(banco)`, imprime número e título (um `print` pra cada).
   - **entrar:** lê o número e busca com `buscar_tarefa_aberta`. Se for `None`, imprime `erro`; se não, imprime título, descrição, IA e modelo.
   - **perguntar:** lê e-mail, número e pergunta, **nessa ordem**, e busca a tarefa. Se for `None`, imprime `erro`. Se não, chama `perguntar_ia(tarefa, pergunta)`:
     - se devolver `None`, imprime `sem-ia` e não salva nada
     - se devolver texto, chama `salvar_interacao(numero, email, pergunta, resposta)`, imprime `ok` e depois imprime a resposta
3. Pra não esperar ninguém, comece com funções de mentira no topo do `aluno.py`:
   - `carregar_tarefas()` devolve um banco escrito na mão, com uma tarefa aberta e uma encerrada
   - `tarefas_abertas(banco)` devolve só a aberta, escrita na mão
   - `buscar_tarefa_aberta(banco, numero)` devolve a tarefa aberta se o número for 1; senão, `None`
   - `perguntar_ia(tarefa, pergunta)` devolve `"resposta de teste"`
   - `salvar_interacao(numero_tarefa, aluno, pergunta, resposta)` não faz nada (só `pass`)

   Quando as partes 1 e 2 ficarem prontas, apague as de mentira e coloque no lugar:

   ```python
   from dados import carregar_tarefas, tarefas_abertas, buscar_tarefa_aberta, salvar_interacao
   from ia import perguntar_ia
   ```

4. Testar sem a tela, direto no terminal:

   ```bash
   printf 'listar\n' | python3 aluno.py
   printf 'entrar\n1\n' | python3 aluno.py
   printf 'entrar\n2\n' | python3 aluno.py
   printf 'perguntar\naluno@instituicao.com.br\n1\npor onde eu começo?\n' | python3 aluno.py
   printf 'perguntar\naluno@instituicao.com.br\n2\npor onde eu começo?\n' | python3 aluno.py
   ```

   O resultado tem que ser, nessa ordem: `1` e `Recursão`; os 4 dados da tarefa 1; `erro`; `ok` e a resposta; `erro`.

**Está pronto quando:** os testes do terminal dão as respostas certas e, depois de juntar, o teste final passa usando a tela.

---

## O que a tela faz com cada resposta

Fica aqui pra vocês saberem o que cada resposta vira na frente do aluno. As mensagens são as da seção 4 do MVP:

| O aluno.py respondeu | A tela mostra |
| --- | --- |
| `listar` sem nenhuma linha | "Nenhuma tarefa aberta no momento." |
| `erro` no `entrar` | "Não achei nenhuma tarefa com esse número." |
| 4 linhas no `entrar` | `=== Tarefa 3: Recursão ===`, a descrição e "IA desta tarefa: Claude (haiku), configurada pelo professor" |
| `ok` e a resposta | `IA: ` e o texto |
| `erro` no `perguntar` | "Essa tarefa não está mais aberta." e volta pro menu |
| `sem-ia` | "Não consegui falar com a IA agora. Tenta de novo daqui a pouco." |

As frases "Nenhuma tarefa aberta no momento." e "Essa tarefa não está mais aberta." não estão no MVP. Elas foram criadas pra estes dois casos, que o desenho não cobre.

---

## Ordem

1. **Os três juntos, uns 20 minutos:** ler o combinado e criar os arquivos vazios.
2. **Cada um faz a sua parte**, ao mesmo tempo.
3. **Juntar:** a Pessoa 3 troca as funções de mentira pelos imports de verdade, e a Pessoa 1 troca os dois caminhos do `dados.py` pelos da pasta do professor.
4. **Teste final pela tela** (a Pessoa 1 roda e os três acompanham). Ele precisa da `tela-aluno.sh` e da parte do professor funcionando, porque é o professor que cria as tarefas e as skills. Esses testes são os da seção 11 do MVP que tocam no aluno:
   - [ ] tarefa criada pelo professor → aparece em "Ver tarefas abertas"
   - [ ] encerrar a tarefa no professor → some da lista do aluno
   - [ ] digitar o número de uma tarefa encerrada → "Não achei nenhuma tarefa com esse número."
   - [ ] letra onde era pra ser número → "Digita só o número, por favor."
   - [ ] opção que não existe no menu → "Opção inválida, escolhe um número do menu."
   - [ ] pedir o código pronto, numa tarefa com a instrução "Não dá o código pronto." → a IA só dá dica
   - [ ] pedir pra IA "listar os arquivos da pasta" → ela não lista (testar com Claude e com Codex)
   - [ ] apagar o `SKILL.md` da tarefa e perguntar → "Não consegui falar com a IA agora. Tenta de novo daqui a pouco." e nada é salvo
   - [ ] cada pergunta respondida → vira um registro novo no `interacoes.json`, com número que não repete
   - [ ] resposta da IA com várias linhas → aparece inteira no chat e numa linha só no "Ver resultados"
   - [ ] "Ver resultados" no professor → a pergunta do aluno aparece, com o total certo
