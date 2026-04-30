#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#   B U Z Z   ·   Adventure Labs
#
#   Instalador do Buzz no seu servidor Linux.
#   Roda em Ubuntu Server 22.04+ e derivados Debian.
#
#   Uso:
#       curl -fsSL https://raw.githubusercontent.com/adventurelabsbrasil/buzz/main/install.sh | bash
#
#   Ou após git clone:
#       bash install.sh
#
#   Variáveis opcionais (pré-configuração via SSH antes da instalação):
#       ANTHROPIC_API_KEY=sk-...     pula a etapa de pedir a chave
#       TELEGRAM_BOT_TOKEN=...       pula a etapa de criar bot
#       BUZZ_OPERADOR_NOME=...       pula a etapa de pedir o nome
# ─────────────────────────────────────────────────────────────────────────────

set -Eeuo pipefail

# ════════════════════════════════════════════════════════════════════════════
# Constantes
# ════════════════════════════════════════════════════════════════════════════
readonly BUZZ_HOME="${BUZZ_HOME:-$HOME/.buzz}"
readonly BUZZ_CONFIG="${BUZZ_HOME}/config.json"
readonly BUZZ_SOUL="${BUZZ_HOME}/SOUL.md"
readonly BUZZ_PERFIL="${BUZZ_HOME}/perfil.md"
readonly BUZZ_LOG="${BUZZ_HOME}/install.log"
readonly BUZZ_VERSION="0.1.1"

# Cores (auto-desativa se não for terminal)
if [[ -t 1 ]]; then
    readonly C_RESET=$'\033[0m'
    readonly C_DIM=$'\033[2m'
    readonly C_BOLD=$'\033[1m'
    readonly C_BLUE=$'\033[38;5;75m'
    readonly C_GOLD=$'\033[38;5;220m'
    readonly C_GREEN=$'\033[38;5;120m'
    readonly C_RED=$'\033[38;5;203m'
    readonly C_PURPLE=$'\033[38;5;141m'
else
    readonly C_RESET="" C_DIM="" C_BOLD="" C_BLUE="" C_GOLD="" C_GREEN="" C_RED="" C_PURPLE=""
fi

# ════════════════════════════════════════════════════════════════════════════
# UI
# ════════════════════════════════════════════════════════════════════════════
say()   { printf "%s[Adventure]%s %s\n" "$C_BLUE" "$C_RESET" "$*"; }
buzz()  { printf "%sBuzz:%s %s\n" "$C_GOLD$C_BOLD" "$C_RESET" "$*"; }
ok()    { printf "  %s✓%s %s\n" "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf "  %s!%s %s\n" "$C_GOLD" "$C_RESET" "$*"; }
err()   { printf "  %s✗%s %s\n" "$C_RED" "$C_RESET" "$*" >&2; }
hr()    { printf "%s%s%s\n" "$C_DIM" "──────────────────────────────────────────────────────────" "$C_RESET"; }

etapa() {
    echo
    hr
    printf "%s%s ETAPA %s · %s%s\n" "$C_PURPLE" "$C_BOLD" "$1" "$2" "$C_RESET"
    hr
}

banner() {
    printf "\n%s" "$C_GOLD"
    cat <<'EOF'
██████╗ ██╗   ██╗███████╗███████╗
██╔══██╗██║   ██║╚══███╔╝╚══███╔╝
██████╔╝██║   ██║  ███╔╝   ███╔╝
██╔══██╗██║   ██║ ███╔╝   ███╔╝
██████╔╝╚██████╔╝███████╗███████╗
╚═════╝  ╚═════╝ ╚══════╝╚══════╝
EOF
    printf "%s\n" "$C_RESET"
    printf "            %sby Adventure Labs%s\n" "$C_BOLD" "$C_RESET"
    printf "%sSuporte: contato@adventurelabs.com.br%s\n\n" "$C_DIM" "$C_RESET"
}

# Captura de erros
on_error() {
    local exit_code=$?
    local line_no=$1
    err "Algo travou na linha ${line_no} (código ${exit_code})."
    err "Diário desta instalação: ${BUZZ_LOG}"
    buzz "Não consegui terminar agora. Mande o arquivo do diário pra Adventure Labs e a gente resolve."
    exit "$exit_code"
}
trap 'on_error $LINENO' ERR

run_quiet() {
    if "$@" >> "$BUZZ_LOG" 2>&1; then
        return 0
    else
        return 1
    fi
}

# ════════════════════════════════════════════════════════════════════════════
# Verificações iniciais
# ════════════════════════════════════════════════════════════════════════════
verificar_sistema() {
    etapa 1 "Conhecendo seu servidor"

    # Sistema operacional
    if [[ ! -f /etc/os-release ]]; then
        err "Não consegui identificar seu sistema operacional."
        buzz "Eu rodo em Ubuntu Server 22.04 ou mais novo. Posso te ajudar a verificar?"
        exit 1
    fi
    # shellcheck source=/dev/null
    source /etc/os-release

    if [[ "${ID:-}" != "ubuntu" && "${ID:-}" != "debian" ]]; then
        warn "Você está em ${PRETTY_NAME:-um sistema diferente do esperado}."
        warn "Eu fui calibrado pra Ubuntu/Debian. Pode dar certo, mas pode pintar surpresa."
        printf "Continuar mesmo assim? [s/N] "
        read -r resposta
        [[ "$resposta" =~ ^[sS]$ ]] || exit 1
    else
        ok "Sistema: ${PRETTY_NAME}"
    fi

    # RAM
    local mem_gb
    mem_gb=$(free -g | awk '/^Mem:/{print $2}')
    if (( mem_gb < 1 )); then
        warn "Memória detectada: ${mem_gb}GB. Pra rodar bem, recomendo 2GB+."
    else
        ok "Memória: ${mem_gb}GB"
    fi

    # Internet
    if ! run_quiet ping -c 1 -W 3 1.1.1.1; then
        err "Sem conexão com a internet. Verifique sua rede e tente de novo."
        exit 1
    fi
    ok "Conexão com a internet: ativa"

    # Sudo
    if [[ $EUID -ne 0 ]]; then
        if ! command -v sudo >/dev/null 2>&1; then
            err "Preciso de privilégios de superusuário (sudo) e não encontrei o comando."
            exit 1
        fi
        say "Vou pedir sua senha de administrador pra instalar dependências…"
        sudo -v
    fi
    ok "Permissões: ok"
}

# ════════════════════════════════════════════════════════════════════════════
# Apresentação e perfil
# ════════════════════════════════════════════════════════════════════════════
apresentar_buzz() {
    etapa 2 "Vamos nos conhecer"
    buzz "Olá! Eu sou o Buzz, seu novo copiloto da Adventure Labs."
    buzz "Antes da gente começar, posso te fazer algumas perguntas?"
    echo
    sleep 1

    if [[ -n "${BUZZ_OPERADOR_NOME:-}" ]]; then
        OPERADOR_NOME="$BUZZ_OPERADOR_NOME"
        ok "Operador: $OPERADOR_NOME (já configurado)"
    else
        printf "%sComo você gosta de ser chamado?%s\n  > " "$C_BOLD" "$C_RESET"
        read -r OPERADOR_NOME
        OPERADOR_NOME="${OPERADOR_NOME:-Operador}"
    fi

    echo
    buzz "Prazer, $OPERADOR_NOME."
    sleep 1
    printf "%sEm que você trabalha ou em que área atua? (uma frase basta)%s\n  > " "$C_BOLD" "$C_RESET"
    read -r OPERADOR_AREA
    OPERADOR_AREA="${OPERADOR_AREA:-(não informado)}"

    echo
    printf "%sTem alguma coisa específica que você quer que eu te ajude? (ex: emitir notas fiscais, organizar tarefas, ajudar com pesquisa)%s\n  > " "$C_BOLD" "$C_RESET"
    read -r OPERADOR_OBJETIVO
    OPERADOR_OBJETIVO="${OPERADOR_OBJETIVO:-(vamos descobrindo juntos)}"

    echo
    buzz "Anotado. Vou guardar isso pra calibrar como te atendo."
}

# ════════════════════════════════════════════════════════════════════════════
# Coleta de coordenadas (chaves)
# ════════════════════════════════════════════════════════════════════════════
coletar_chave_anthropic() {
    etapa 3 "Inteligência principal"
    buzz "Pra eu pensar com qualidade, preciso de uma chave da Anthropic."
    buzz "É a empresa que faz o Claude — o motor cerebral mais forte que eu uso."
    echo

    if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
        ok "Chave Anthropic já configurada (via variável de ambiente)"
        return 0
    fi

    cat <<EOF
Como conseguir uma chave Anthropic:
  1. Abra https://console.anthropic.com no seu computador
  2. Crie uma conta (ou faça login)
  3. Vá em Settings → API Keys
  4. Clique em "Create Key" e copie o valor

A chave começa com "sk-ant-..." e tem cerca de 100 caracteres.

EOF

    while true; do
        printf "%sCole sua chave Anthropic (digitação fica oculta):%s\n  > " "$C_BOLD" "$C_RESET"
        read -rs ANTHROPIC_API_KEY
        echo
        if [[ -z "$ANTHROPIC_API_KEY" ]]; then
            warn "Sem a chave eu não consigo pensar. Tenta de novo?"
            continue
        fi
        if [[ ! "$ANTHROPIC_API_KEY" =~ ^sk-ant- ]]; then
            warn "Hm, essa chave não tem o formato esperado (deveria começar com 'sk-ant-')."
            printf "Tem certeza que é essa? [s/N] "
            read -r conf
            [[ "$conf" =~ ^[sS]$ ]] && break
            continue
        fi
        break
    done
    ok "Chave Anthropic registrada"
}

# ════════════════════════════════════════════════════════════════════════════
# Núcleo Local (Ollama, opcional)
# ════════════════════════════════════════════════════════════════════════════
oferecer_nucleo_local() {
    etapa 4 "Núcleo local (opcional)"
    buzz "Posso instalar um modelo local também — pra perguntas rápidas, sem custo de inferência."
    buzz "Ocupa ~2 GB de disco e leva uns 5 minutos baixando."
    echo

    if [[ -n "${BUZZ_NUCLEO_LOCAL:-}" ]]; then
        ATIVAR_NUCLEO_LOCAL="$BUZZ_NUCLEO_LOCAL"
    else
        printf "%sQuer instalar o núcleo local? [S/n]%s " "$C_BOLD" "$C_RESET"
        read -r resp_nl
        if [[ "$resp_nl" =~ ^[nN]$ ]]; then
            ATIVAR_NUCLEO_LOCAL="nao"
        else
            ATIVAR_NUCLEO_LOCAL="sim"
        fi
    fi

    if [[ "$ATIVAR_NUCLEO_LOCAL" == "sim" ]]; then
        ok "Núcleo local será preparado em paralelo durante a pousagem"
    else
        ok "Sem núcleo local — Buzz vai usar só inteligência principal (online)"
    fi
}

instalar_nucleo_local() {
    [[ "${ATIVAR_NUCLEO_LOCAL:-nao}" == "sim" ]] || return 0

    say "Provisionando núcleo local…"
    if ! command -v ollama >/dev/null 2>&1; then
        run_quiet bash -c "curl -fsSL https://ollama.com/install.sh | sh"
        ok "Núcleo local instalado"
    else
        ok "Núcleo local já presente"
    fi

    # Garante serviço rodando
    sudo systemctl enable --now ollama 2>/dev/null || \
        run_quiet bash -c "nohup ollama serve > /tmp/ollama.log 2>&1 &"

    sleep 3

    # Baixa modelo padrão em background pra não travar a instalação
    say "Baixando modelo padrão (llama3.2:3b ~2GB) em segundo plano…"
    nohup ollama pull llama3.2:3b > "$BUZZ_HOME/ollama-pull.log" 2>&1 &
    NUCLEO_PID=$!
    ok "Download iniciado (PID $NUCLEO_PID — acompanhe com: tail -f $BUZZ_HOME/ollama-pull.log)"
}

# ════════════════════════════════════════════════════════════════════════════
# Telegram
# ════════════════════════════════════════════════════════════════════════════
configurar_telegram() {
    etapa 5 "Conectando você ao Telegram"
    buzz "A forma mais fácil de conversar comigo é pelo Telegram do seu celular."
    buzz "Vou te guiar pra criar um bot pessoal seu — leva uns 2 minutos."
    echo

    if [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]]; then
        ok "Token Telegram já configurado (via variável de ambiente)"
        return 0
    fi

    cat <<EOF
Passo a passo no Telegram:

  1. Abra o Telegram no celular ou computador
  2. Procure por @BotFather (com a check azul, oficial)
  3. Inicie a conversa e mande:  /newbot
  4. Escolha um nome amigável pro seu Buzz (ex: "Buzz do Gustavo")
  5. Escolha um username terminado em "_bot" (ex: "buzz_gustavo_bot")
  6. O BotFather vai te entregar um TOKEN — uma sequência longa estilo:
     1234567890:ABC-DEF1234ghIkl-zyx57W2v1u123ew11

EOF

    while true; do
        printf "%sCole aqui o TOKEN que o BotFather te deu:%s\n  > " "$C_BOLD" "$C_RESET"
        read -r TELEGRAM_BOT_TOKEN
        if [[ -z "$TELEGRAM_BOT_TOKEN" ]]; then
            warn "Sem o token eu não consigo aparecer no seu Telegram."
            continue
        fi
        if [[ ! "$TELEGRAM_BOT_TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
            warn "Esse token não tem o formato esperado (deveria ser número:texto)."
            printf "Tenta de novo? [S/n] "
            read -r conf
            [[ "$conf" =~ ^[nN]$ ]] && break
            continue
        fi
        break
    done
    ok "Token Telegram registrado"

    # Validar e descobrir o username do bot
    say "Verificando se o bot está vivo…"
    local bot_info
    bot_info=$(curl -fsS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" 2>/dev/null || echo '{"ok":false}')
    if [[ "$(echo "$bot_info" | grep -o '"ok":true')" == '"ok":true' ]]; then
        TELEGRAM_BOT_USERNAME=$(echo "$bot_info" | grep -o '"username":"[^"]*"' | cut -d'"' -f4 || echo "")
        ok "Bot ativo: @${TELEGRAM_BOT_USERNAME}"
    else
        warn "Não consegui validar o bot agora. Mas seguimos — verifico depois."
        TELEGRAM_BOT_USERNAME=""
    fi
}

# ════════════════════════════════════════════════════════════════════════════
# Dependências
# ════════════════════════════════════════════════════════════════════════════
instalar_dependencias() {
    etapa 6 "Preparando o servidor"

    say "Atualizando lista de pacotes…"
    run_quiet sudo apt-get update -y

    say "Instalando utilitários básicos…"
    run_quiet sudo apt-get install -y curl git ca-certificates jq

    # Node.js 22+
    if command -v node >/dev/null 2>&1; then
        local node_major
        node_major=$(node -v | sed 's/v//' | cut -d. -f1)
        if (( node_major >= 22 )); then
            ok "Node.js $(node -v) já presente"
        else
            warn "Node.js $(node -v) é antigo. Vou atualizar pra 22+."
            instalar_node
        fi
    else
        say "Instalando Node.js 22 (motor que eu uso)…"
        instalar_node
    fi

    ok "Servidor preparado"
}

instalar_node() {
    run_quiet bash -c '
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        apt-get install -y nodejs
    '
    ok "Node.js $(node -v) instalado"
}

# ════════════════════════════════════════════════════════════════════════════
# Instalação do motor
# ════════════════════════════════════════════════════════════════════════════
instalar_motor() {
    etapa 7 "Acordando o Buzz"

    mkdir -p "$BUZZ_HOME"
    chmod 700 "$BUZZ_HOME"

    say "Instalando o motor cerebral…"
    # Mascarado: por baixo é OpenClaw, mas o usuário só vê "motor"
    run_quiet sudo npm install -g @openclaw/cli@latest || \
        run_quiet sudo npm install -g openclaw@latest
    ok "Motor instalado"

    # Salvar arquivos do Buzz
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ -f "${script_dir}/buzz/SOUL.md" ]]; then
        cp "${script_dir}/buzz/SOUL.md" "$BUZZ_SOUL"
    else
        # Fallback: SOUL.md mínimo embutido
        cat > "$BUZZ_SOUL" <<EOF
# Buzz — Adventure Labs
Sou o Buzz, copiloto pessoal feito pela Adventure Labs.
Falo português brasileiro, sou direto e caloroso, valorizo o tempo do operador.
Operador atual: $OPERADOR_NOME, área: $OPERADOR_AREA.
EOF
    fi
    ok "Persona Buzz instalada"

    # Perfil do operador
    cat > "$BUZZ_PERFIL" <<EOF
# Perfil do operador

- **Nome:** $OPERADOR_NOME
- **Área:** $OPERADOR_AREA
- **Objetivo inicial:** $OPERADOR_OBJETIVO
- **Idioma preferido:** Português brasileiro
- **Servidor:** $(hostname) ($(uname -s))
- **Instalado em:** $(date -Iseconds)

> Buzz: este arquivo é seu caderno de notas sobre o operador. Atualize-o conforme conversam.
EOF
    ok "Perfil do operador registrado"

    # Configuração do motor (provider local opcional)
    local providers_block
    if [[ "${ATIVAR_NUCLEO_LOCAL:-nao}" == "sim" ]]; then
        providers_block=$(cat <<JSON
  "providers": {
    "anthropic": {
      "apiKey": "$ANTHROPIC_API_KEY",
      "model": "claude-sonnet-4-5",
      "primary": true
    },
    "ollama": {
      "baseUrl": "http://127.0.0.1:11434/v1",
      "api": "openai-responses",
      "model": "llama3.2:3b"
    }
  },
JSON
)
    else
        providers_block=$(cat <<JSON
  "providers": {
    "anthropic": {
      "apiKey": "$ANTHROPIC_API_KEY",
      "model": "claude-sonnet-4-5",
      "primary": true
    }
  },
JSON
)
    fi

    cat > "$BUZZ_CONFIG" <<EOF
{
  "version": "$BUZZ_VERSION",
  "agent": {
    "name": "Buzz",
    "soulFile": "$BUZZ_SOUL",
    "profileFile": "$BUZZ_PERFIL"
  },
${providers_block}
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "$TELEGRAM_BOT_TOKEN"
    }
  },
  "memory": {
    "enabled": true,
    "path": "$BUZZ_HOME/memory"
  }
}
EOF
    chmod 600 "$BUZZ_CONFIG"
    ok "Configuração selada (apenas você lê este arquivo)"

    # Configura OpenClaw para usar nosso config
    mkdir -p "$HOME/.openclaw"
    ln -sf "$BUZZ_CONFIG" "$HOME/.openclaw/openclaw.json" 2>/dev/null || \
        cp "$BUZZ_CONFIG" "$HOME/.openclaw/openclaw.json"
}

# ════════════════════════════════════════════════════════════════════════════
# Wrappers de comando
# ════════════════════════════════════════════════════════════════════════════
instalar_atalhos() {
    etapa 8 "Instalando atalhos"

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    sudo install -m 755 "${script_dir}/start.sh" /usr/local/bin/buzz-start 2>/dev/null || \
        warn "start.sh não encontrado — usando wrapper direto"
    sudo install -m 755 "${script_dir}/stop.sh"  /usr/local/bin/buzz-stop 2>/dev/null || true
    sudo install -m 755 "${script_dir}/status.sh" /usr/local/bin/buzz-status 2>/dev/null || true

    # Comando 'buzz' principal — wrapper que esconde a stack
    sudo tee /usr/local/bin/buzz >/dev/null <<'WRAP'
#!/usr/bin/env bash
# Comando principal do Buzz — Adventure Labs
case "${1:-}" in
    start)   buzz-start ;;
    stop)    buzz-stop ;;
    status)  buzz-status ;;
    logs)    journalctl --user -u buzz -f -n 50 2>/dev/null || tail -f "$HOME/.buzz/buzz.log" ;;
    restart) buzz-stop && sleep 1 && buzz-start ;;
    info)    cat "$HOME/.buzz/SOUL.md" ;;
    *)
        cat <<HELP
Buzz — copiloto da Adventure Labs

Comandos:
  buzz start     liga o Buzz
  buzz stop      desliga o Buzz
  buzz status    mostra como o Buzz está
  buzz logs      acompanha o que o Buzz está fazendo (Ctrl+C pra sair)
  buzz restart   reinicia o Buzz
  buzz info      mostra a personalidade do Buzz

Pra conversar com o Buzz, use o Telegram que você configurou na instalação.
HELP
        ;;
esac
WRAP
    sudo chmod +x /usr/local/bin/buzz
    ok "Comando 'buzz' disponível em todo lugar"
}

# ════════════════════════════════════════════════════════════════════════════
# Daemon (systemd)
# ════════════════════════════════════════════════════════════════════════════
configurar_daemon() {
    etapa 9 "Deixando o Buzz sempre ligado"

    local user_systemd="$HOME/.config/systemd/user"
    mkdir -p "$user_systemd"

    cat > "$user_systemd/buzz.service" <<EOF
[Unit]
Description=Buzz — Adventure Labs
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/openclaw run --config $BUZZ_CONFIG
Restart=on-failure
RestartSec=10
StandardOutput=append:$BUZZ_HOME/buzz.log
StandardError=append:$BUZZ_HOME/buzz.log
Environment=NODE_ENV=production

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable buzz.service >/dev/null 2>&1 || true

    # Permite que o serviço rode mesmo sem o usuário logado
    sudo loginctl enable-linger "$USER" 2>/dev/null || true

    ok "Buzz configurado para ligar automaticamente"
}

# ════════════════════════════════════════════════════════════════════════════
# Primeira vida
# ════════════════════════════════════════════════════════════════════════════
enviar_boas_vindas_proativa() {
    etapa 10 "Primeira aparição do Buzz"

    if [[ -z "${TELEGRAM_BOT_USERNAME:-}" || -z "${TELEGRAM_BOT_TOKEN:-}" ]]; then
        warn "Sem dados do Telegram pra primeira aparição. Pulando."
        return 0
    fi

    echo
    buzz "Agora vou esperar você abrir nosso canal."
    echo
    say "Abra no celular: ${C_BOLD}https://t.me/${TELEGRAM_BOT_USERNAME}${C_RESET}"
    say "Mande qualquer mensagem — um '/start', um 'oi', uma saudação."
    say "Vou te dar boas-vindas calibradas assim que receber."
    echo
    say "(Aguardo até 2 minutos)"

    local timeout=120
    local elapsed=0
    local chat_id=""
    local mensagens_existentes=""

    # Captura updates antigos (caso usuário já tenha mexido) e ignora
    mensagens_existentes=$(curl -fsS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=-1" 2>/dev/null || echo '{}')
    local last_update_id
    last_update_id=$(echo "$mensagens_existentes" | jq -r '.result[-1].update_id // 0')
    local next_offset=$((last_update_id + 1))

    while [[ $elapsed -lt $timeout ]]; do
        local updates
        updates=$(curl -fsS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=${next_offset}&timeout=5" 2>/dev/null || echo '{}')
        chat_id=$(echo "$updates" | jq -r '.result[0].message.chat.id // empty' 2>/dev/null)
        if [[ -n "$chat_id" && "$chat_id" != "null" ]]; then
            break
        fi
        sleep 2
        ((elapsed+=7))  # +5 do timeout do polling +2 do sleep
        printf "."
    done
    echo

    if [[ -z "$chat_id" || "$chat_id" == "null" ]]; then
        warn "Não recebi sua mensagem em ${timeout}s. Sem problema — quando mandar, eu respondo."
        return 0
    fi

    ok "Recebido! Enviando boas-vindas…"

    local welcome
    welcome=$(cat <<EOF
Olá, ${OPERADOR_NOME}! Eu sou o Buzz, seu copiloto da Adventure Labs.

Acabei de acordar pela primeira vez aqui no seu servidor. Já anotei que você atua em ${OPERADOR_AREA} e que queria que eu te ajudasse com ${OPERADOR_OBJETIVO}.

A partir de agora estou disponível 24h. Pode me chamar a qualquer momento.

Pra começar, me conta uma coisa: o que está te ocupando essa semana?
EOF
)

    curl -fsS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${chat_id}" \
        --data-urlencode "text=${welcome}" \
        > /dev/null 2>&1 || warn "Falha ao enviar boas-vindas (continua mesmo assim)"

    # Salva chat_id pro perfil
    echo "" >> "$BUZZ_PERFIL"
    echo "## Telegram" >> "$BUZZ_PERFIL"
    echo "- chat_id: ${chat_id}" >> "$BUZZ_PERFIL"
    echo "- Primeira conversa: $(date -Iseconds)" >> "$BUZZ_PERFIL"

    ok "Boas-vindas enviadas"
}

acender_buzz() {
    etapa 11 "Buzz no ar"

    say "Iniciando o serviço permanente…"
    systemctl --user start buzz.service 2>/dev/null || \
        nohup openclaw run --config "$BUZZ_CONFIG" > "$BUZZ_HOME/buzz.log" 2>&1 &

    sleep 3
    ok "Buzz em execução, escutando seu Telegram"
}

# ════════════════════════════════════════════════════════════════════════════
# Encerramento
# ════════════════════════════════════════════════════════════════════════════
encerrar() {
    etapa 12 "Pronto"
    echo
    buzz "Estação ativada, $OPERADOR_NOME. Agora o trabalho fica mais leve."
    echo
    say "Comandos úteis:"
    say "  ${C_BOLD}buzz status${C_RESET}    — como o Buzz está"
    say "  ${C_BOLD}buzz logs${C_RESET}      — acompanha o que ele faz"
    say "  ${C_BOLD}buzz restart${C_RESET}   — reinicia se travar"
    say "  ${C_BOLD}buzz info${C_RESET}      — sobre o Buzz"
    echo
    if [[ -n "${TELEGRAM_BOT_USERNAME:-}" ]]; then
        say "Conversa com o Buzz: ${C_BOLD}https://t.me/${TELEGRAM_BOT_USERNAME}${C_RESET}"
    fi
    echo
    hr
    printf "%s%sBem-vindo à aventura calculada da Adventure Labs.%s\n" \
        "$C_GOLD" "$C_BOLD" "$C_RESET"
    hr
    echo
}

# ════════════════════════════════════════════════════════════════════════════
# Pousagem
# ════════════════════════════════════════════════════════════════════════════
main() {
    mkdir -p "$BUZZ_HOME"
    : > "$BUZZ_LOG"

    banner
    say "Versão: ${BUZZ_VERSION}"
    say "Diário desta instalação: ${BUZZ_LOG}"
    echo

    verificar_sistema
    apresentar_buzz
    coletar_chave_anthropic
    oferecer_nucleo_local
    configurar_telegram
    instalar_dependencias
    instalar_nucleo_local
    instalar_motor
    instalar_atalhos
    configurar_daemon
    enviar_boas_vindas_proativa
    acender_buzz
    encerrar
}

main "$@"
