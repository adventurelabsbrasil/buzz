# Como usar o Buzz no dia a dia

Este é o manual rápido. Pra dúvidas mais profundas, conversa com o próprio Buzz no Telegram — ele explica em detalhe.

## Conversando

Abra o Telegram, vá no canal do seu Buzz, e fale como falaria com qualquer pessoa. Tipo:

> "Buzz, me lembra amanhã às 9h de mandar a mensagem pro João"
>
> "O que rolou de novidade no mercado de IA essa semana?"
>
> "Faz pra mim um resumo do que a gente conversou ontem"
>
> "Me explica o que é uma DRE como se eu fosse leigo"

Não precisa de comando especial. Conversa natural funciona.

## Memória

O Buzz lembra de conversas passadas. Você pode pedir:

> "Lembra que eu te falei sobre o projeto X?"
>
> "Esquece o que eu disse sobre Y"
>
> "Me mostra o que você sabe sobre mim"

A memória dele cresce com o tempo. Quanto mais ele te conhece, mais útil fica.

## Quando algo não funciona

Pergunta direto pra ele primeiro:

> "Buzz, você está bem? Me responde se está tudo ok aí."

Se ele não responder em 30 segundos, vá pro terminal do servidor e:

```bash
buzz status
```

Isso te diz se ele está vivo e se o Telegram está conectado. Se estiver desligado:

```bash
buzz start
```

Se estiver ligado mas estranho:

```bash
buzz restart
```

## Mudando o jeito do Buzz

A personalidade dele mora em `~/.buzz/SOUL.md`. Você pode abrir esse arquivo e ajustar como ele fala, o que valoriza, o que evita.

```bash
nano ~/.buzz/SOUL.md
buzz restart
```

Ou simplesmente fala pra ele:

> "Buzz, fala um pouco mais formal comigo de agora em diante"
>
> "Buzz, gosto quando você é mais direto, menos enrolado"

Ele aprende e se ajusta.

## Apagando informações

Se você não quer mais que ele lembre de algo:

> "Buzz, esquece tudo o que eu te disse sobre [tema]"

Pra apagar tudo de uma vez (perfil, memórias, configurações):

```bash
rm -rf ~/.buzz/memory
buzz restart
```

A persona dele continua, mas ele te conhece de novo do zero.

## O servidor desligou ou caiu a luz

Quando o servidor voltar a ligar, o Buzz volta sozinho — instalei ele pra ligar no boot. Se por algum motivo ele não voltar:

```bash
buzz start
```

## Fim de mês — atenção aos créditos

A Anthropic vai te cobrar pelo que você usar. Coisa de R$ 10–30 por mês de uso normal de uma pessoa. Pra acompanhar:

1. https://console.anthropic.com → Settings → Billing
2. Você vê o consumo do mês corrente
3. Quando os créditos acabam, o Buzz para de responder até você recarregar

Recomendo deixar **alerta de saldo baixo** ativado lá no painel.

## Sentindo falta de algo

Se você acha que o Buzz devia fazer X e não faz, fale comigo (Rodrigo) ou abre uma issue em github.com/adventurelabsbrasil/buzz. A versão atual é MVP — está crescendo conforme as pessoas usam. Suas observações importam.
