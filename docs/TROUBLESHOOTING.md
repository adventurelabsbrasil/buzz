# Problemas conhecidos e soluções

## A instalação travou no meio

Veja o diário da instalação:

```bash
cat ~/.buzz/install.log
```

A linha que diz "Algo travou" indica onde parou. Causas mais comuns:

**Sem internet ou DNS travado.** Teste: `ping 1.1.1.1`. Se não responder, sua rede está com problema, não o Buzz.

**Sem espaço em disco.** Teste: `df -h /`. Se a coluna "Use%" estiver acima de 95%, libere espaço antes de tentar de novo.

**Sem permissão de sudo.** O instalador pede sua senha pra instalar Node.js. Se você não tem privilégio de administrador no servidor, peça pra quem tem.

Depois de resolver, rode de novo:

```bash
bash install.sh
```

Ele detecta o que já foi feito e continua de onde parou.

## O bot do Telegram não responde

Tem três motivos comuns:

**O Buzz está desligado.**

```bash
buzz status
```

Se aparecer "Estado: desligado", ligue:

```bash
buzz start
```

**O token do Telegram está errado.**

```bash
grep botToken ~/.buzz/config.json
```

Compare com o token que o BotFather te deu. Se estiver diferente, edite o arquivo, troque, e reinicie:

```bash
nano ~/.buzz/config.json
buzz restart
```

**A chave Anthropic está sem créditos.**

Vá em https://console.anthropic.com → Settings → Billing. Se o saldo está zerado, recarregue.

## "Permissão negada" ao rodar `buzz`

Provavelmente o instalador não conseguiu colocar os comandos em `/usr/local/bin/`. Rode:

```bash
sudo ln -sf ~/buzz/start.sh /usr/local/bin/buzz-start
sudo ln -sf ~/buzz/stop.sh /usr/local/bin/buzz-stop
sudo ln -sf ~/buzz/status.sh /usr/local/bin/buzz-status
```

E garanta que o usuário pode rodar:

```bash
sudo chmod +x ~/buzz/*.sh
```

## O Buzz responde, mas as respostas estão estranhas / curtas / em inglês

Provavelmente o `SOUL.md` não está sendo lido corretamente. Verifique se o arquivo existe:

```bash
cat ~/.buzz/SOUL.md
```

Se estiver vazio ou ausente, copie do repositório:

```bash
cp ~/buzz/buzz/SOUL.md ~/.buzz/SOUL.md
buzz restart
```

## "openclaw: command not found"

O motor não foi instalado direito. Tente:

```bash
sudo npm install -g openclaw
```

Se der erro, verifique a versão do Node:

```bash
node --version
```

Precisa ser **22 ou mais novo**. Se for menor:

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt-get install -y nodejs
```

E tente instalar o motor de novo.

## O Buzz para sozinho durante a noite

Geralmente é o servidor entrando em modo de economia ou dormindo. Confirme que:

1. O serviço está habilitado pra ligar no boot:
```bash
systemctl --user is-enabled buzz.service
```

Se aparecer "disabled":

```bash
systemctl --user enable buzz.service
```

2. O usuário tem "linger" ativo (permite serviços rodarem sem login):

```bash
sudo loginctl enable-linger $USER
```

3. Se o servidor é um notebook ou máquina pessoal, configure pra **não suspender quando a tampa fecha** ou quando ocioso. Em Ubuntu Server geralmente isso já está ok, mas em desktops Ubuntu:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

## Quero ver o que o Buzz está fazendo agora

```bash
buzz logs
```

Ctrl+C pra sair. Pra ver só os últimos 30 segundos:

```bash
journalctl --user -u buzz --since "30 seconds ago"
```

## Não consigo me conectar ao bot — só vejo "iniciando conversa"

Mande qualquer mensagem (até um "oi") e aguarde uns 5–15 segundos da primeira vez. O Buzz precisa carregar a memória e a personalidade na primeira conversa do dia.

Se passar de 30 segundos sem resposta:

```bash
buzz status   # ver se está ligado
buzz logs     # ver se algum erro apareceu
```

Procure por linhas com "ERROR" ou "Failed" nos logs. Mande pra Adventure Labs se não conseguir resolver.

## Esqueci o token do Telegram

Pode pegar de novo com o BotFather:

1. Abra @BotFather no Telegram
2. Mande `/mybots`
3. Clique no seu bot
4. Clique em "API Token"

Aí cole no `~/.buzz/config.json` e reinicie.

## Última opção: começar do zero

Se nada funcionar e você quiser zerar tudo:

```bash
buzz stop 2>/dev/null
rm -rf ~/.buzz
sudo npm uninstall -g openclaw 2>/dev/null
cd ~/buzz && bash install.sh
```

Você vai perder a memória que o Buzz tinha de você, mas a instalação volta a ser limpa.
