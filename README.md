<div align="center">
<pre>
██████╗ ██╗   ██╗███████╗███████╗
██╔══██╗██║   ██║╚══███╔╝╚══███╔╝
██████╔╝██║   ██║  ███╔╝   ███╔╝ 
██╔══██╗██║   ██║ ███╔╝   ███╔╝  
██████╔╝╚██████╔╝███████╗███████╗
╚═════╝  ╚═════╝ ╚══════╝╚══════╝
</pre>

**by Adventure Labs**

<sub>Suporte: <a href="mailto:contato@adventurelabs.com.br">contato@adventurelabs.com.br</a></sub>

</div>

<p align="center">
  <em>Seu copiloto pessoal, no servidor que é seu.</em>
</p>

<p align="center">
  <img alt="Versão" src="https://img.shields.io/badge/vers%C3%A3o-0.1.0--mvp-blue">
  <img alt="Licença" src="https://img.shields.io/badge/licen%C3%A7a-MIT-green">
  <img alt="Status" src="https://img.shields.io/badge/status-MVP%20em%20testes-orange">
  <img alt="Made in Brazil" src="https://img.shields.io/badge/feito%20no-Brasil-yellow">
</p>

> **Status:** versão 0.1 (MVP) em testes com grupo fechado.
> Funciona, mas você é parte da história — feedback é bem-vindo via [Issues](https://github.com/adventurelabsbrasil/buzz/issues).

---

## O que é

**Buzz** é um assistente pessoal feito pela Adventure Labs no Brasil. Ele mora num servidor seu, conversa com você pelo Telegram (e pelo terminal, se quiser), e te ajuda no dia a dia: lembra de coisas, responde dúvidas, executa tarefas, e aprende seu jeito.

Diferente de outras IAs, o Buzz é **seu**. Os dados ficam no seu servidor. As chaves são suas. A personalidade dele se ajusta ao seu jeito de trabalhar conforme vocês conversam.

Esta é a versão **0.1 (MVP)** — em testes com um grupo pequeno antes do lançamento público.

---

## O que você precisa antes de começar

Três coisas. Sem nenhuma delas, melhor não começar — você ia travar no meio.

**Um servidor Linux ligado**, rodando Ubuntu Server 22.04 ou mais novo (Debian também serve). Pode ser um mini-PC na sua casa, uma VPS na internet, um Raspberry Pi 4 ou 5, ou qualquer máquina Linux que você tenha. Mínimo de 2 GB de RAM e 10 GB de espaço em disco. Se você não tem servidor mas tem um computador velho ligado em casa, dá pra usar.

**Uma chave da Anthropic** (a empresa que faz o Claude — o motor cerebral do Buzz). É grátis criar conta, e o uso normal custa em torno de R$ 10–30 por mês dependendo de quanto você conversa. Como pegar:
1. Vá em https://console.anthropic.com
2. Crie conta (ou faça login)
3. Vá em **Settings → API Keys**
4. Clique **Create Key** e copie o valor (começa com `sk-ant-...`)
5. Recarregue créditos em **Settings → Billing** — comece com $5 ou $10, dura bastante

**Um celular com Telegram instalado**. Se ainda não tem, baixe na loja de apps. É gratuito.

---

## Instalação em 4 passos

### Passo 1 — Acesse seu servidor

No computador ou notebook que você usa normalmente, abra um terminal e conecte no seu servidor por SSH:

```bash
ssh seu-usuario@ip-do-seu-servidor
```

Se você não sabe como fazer isso, peça ajuda pra quem te indicou o Buzz — esse passo precisa de um pouco de noção de Linux.

### Passo 2 — Baixe o Buzz

Já dentro do servidor, rode:

```bash
git clone https://github.com/adventurelabsbrasil/buzz.git
cd buzz
```

### Passo 3 — Instale

Ainda no servidor, na pasta `buzz`:

```bash
bash install.sh
```

A instalação é guiada — o próprio Buzz vai conversar com você no terminal e te pedir o que precisa, na hora que precisa. Vai levar entre 5 e 15 minutos dependendo da velocidade do seu servidor.

Durante a instalação, o Buzz vai:

1. Cumprimentar você e perguntar seu nome
2. Perguntar em que área você atua
3. Perguntar o que você gostaria que ele te ajudasse
4. Pedir sua chave Anthropic
5. Te guiar pra criar um bot no Telegram (passo a passo)
6. Instalar tudo o que precisa
7. Acender pela primeira vez

No final, ele vai te dar um link `https://t.me/seu_buzz_bot` — esse é seu canal de conversa com ele.

### Passo 4 — Diga "oi"

Abra o link no Telegram e mande qualquer mensagem. O Buzz responde na hora.

A partir desse momento, ele é seu.

---

## Comandos básicos

Depois da instalação, no terminal do servidor:

```bash
buzz status     # ver se o Buzz está ligado
buzz logs       # acompanhar o que ele está fazendo (Ctrl+C pra sair)
buzz restart    # reiniciar se algo travar
buzz stop       # desligar (ele para de responder no Telegram)
buzz start      # ligar de novo
buzz info       # ver a personalidade do Buzz
```

Pra **conversar** com o Buzz, use o Telegram. O terminal é só pra controlar a estação.

---

## Quanto custa

A instalação e o uso do Buzz são **gratuitos** — o código é aberto.

O que você paga (direto pra Anthropic, não pra Adventure Labs):

- Inferência de IA: cerca de R$ 10–30 por mês de uso normal. Cada conversa consome alguns centavos. A Anthropic mostra seu consumo em tempo real no painel deles.

O que **não** custa:

- Bot do Telegram: grátis pra sempre.
- Servidor: você já tem (ou aluga uma VPS por uns R$ 25/mês se quiser uma dedicada).
- Software: opensource, MIT.

---

## Privacidade

- **O Buzz roda no seu servidor**. A Adventure Labs não tem acesso aos seus dados, conversas ou arquivos.
- **Suas conversas vão direto pra Anthropic** (que processa a IA) e voltam. A Anthropic tem política própria de privacidade.
- **A chave da Anthropic é sua**. Fica num arquivo no seu servidor com permissão restrita (só você lê).
- **Você pode apagar tudo** a qualquer momento removendo a pasta `~/.buzz/`.

---

## E se algo der errado?

Primeiro, tente o básico:

```bash
buzz status     # ver o que está acontecendo
buzz logs       # ler as mensagens (Ctrl+C pra sair)
buzz restart    # reiniciar
```

Se ainda assim não funcionar, abra um issue em **github.com/adventurelabsbrasil/buzz/issues** com:
1. O que você tentou fazer
2. O que apareceu na tela
3. As últimas linhas de `buzz logs`

Ou mande mensagem pra quem te indicou o Buzz — provavelmente foi alguém da Adventure Labs e pode te socorrer rapidinho.

---

## Atualizar o Buzz

Quando sair uma versão nova:

```bash
cd buzz
git pull
bash install.sh
```

A instalação vai detectar que o Buzz já existe e só atualizar o que mudou — sem perder seu perfil, suas conversas ou suas configurações.

---

## Desinstalar

Se um dia quiser tirar o Buzz do servidor:

```bash
buzz stop
rm -rf ~/.buzz
sudo rm /usr/local/bin/buzz /usr/local/bin/buzz-start /usr/local/bin/buzz-stop /usr/local/bin/buzz-status
sudo npm uninstall -g openclaw 2>/dev/null || true
```

Pronto. O Buzz vai embora sem deixar rastro.

---

## Licença

MIT. Construído sobre tecnologia opensource (Node.js, OpenClaw e outros). Adventure Labs embala, dá personalidade e mantém.

---

<p align="center">
  <sub>Trabalhar é uma aventura calculada, não um fardo.</sub><br>
  <sub><a href="https://adventurelabs.com.br">Adventure Labs</a> · Caxias do Sul · RS · Brasil</sub>
</p>
