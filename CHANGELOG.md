# Histórico de versões

Este arquivo registra cada versão do Buzz, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e versionamento semântico [SemVer](https://semver.org/lang/pt-BR/).

Tipos de mudança: **Adicionado** (novo recurso), **Mudado** (alteração em recurso existente), **Removido** (recurso retirado), **Corrigido** (bug consertado), **Segurança** (correção de vulnerabilidade).

---

## [Não lançado]

Mudanças planejadas pra próxima versão. Nada aqui ainda.

---

## [0.1.1] — 2026-04-30

### Adicionado
- **Núcleo local opcional** (Ollama com llama3.2:3b ~2GB) — instalado em paralelo durante a pousagem se o operador escolher
- **Boas-vindas proativa pelo Telegram** — após o setup, instalador faz polling de até 2 minutos e envia primeira mensagem personalizada com nome, área e objetivo do operador assim que ele iniciar o bot
- **Banner ASCII consistente** com o do README (alinhamento corrigido)
- **chat_id persistido em `perfil.md`** — Buzz pode enviar mensagens proativas em conversas futuras sem depender de o operador escrever primeiro

### Mudado
- Etapas do instalador renumeradas (de 10 pra 12) por causa das novas fases
- Configuração `config.json` agora inclui bloco `providers.ollama` quando núcleo local ativado
- Anthropic marcado como `"primary": true` no config quando há múltiplos providers

### Limitações conhecidas
- Modelo local llama3.2:3b é o único oferecido na v0.1.1 (sem opção de escolha entre tamanhos no wizard ainda)
- Smart routing entre providers ainda fica por conta do OpenClaw default — Buzz Router proprietário continua planejado pra v0.7

---

## [0.1.0-mvp] — 2026-04-29

Primeira pousagem. MVP em fase de teste com grupo fechado (família e amigos próximos do founder).

### Adicionado
- Banner ASCII art "BUZZ" no README e no terminal durante a instalação
- Linha de suporte oficial: contato@adventurelabs.com.br
- Instalador interativo `install.sh` em português, com onboarding conversacional
- Comando `buzz` no path com subcomandos `start`, `stop`, `status`, `restart`, `logs`, `info`
- Persona Buzz em `SOUL.md` — voz, valores e regras embutidas
- Configuração persistente em `~/.buzz/` (config, soul, perfil, memória)
- Canal Telegram pré-configurado durante a instalação (BotFather guiado)
- Provider Anthropic (Claude Sonnet) como motor cerebral default
- Daemon systemd `--user` com auto-restart e linger
- Documentação: README, COMO-USAR, TROUBLESHOOTING

### Limitações conhecidas
- Apenas Anthropic suportado (Google AI e modelos locais ficam pra v0.2)
- Apenas Telegram como canal (WhatsApp e Discord ficam pra v0.3)
- Sem skills concretas — só conversa geral (NF MEI e Shopee→Sheets ficam pra v0.2 e v0.3)
- Sem dashboard de uso/custo (v0.4)
- Sem multi-idioma (apenas PT-BR; EN e ES ficam pra v0.5)
- Sem GUI/Web UI (v0.6)
