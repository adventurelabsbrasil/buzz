#!/usr/bin/env bash
# buzz-status — mostra como o Buzz está
set -e

BUZZ_HOME="${BUZZ_HOME:-$HOME/.buzz}"
BUZZ_CONFIG="${BUZZ_HOME}/config.json"

C_GREEN=$'\033[38;5;120m'
C_RED=$'\033[38;5;203m'
C_GOLD=$'\033[38;5;220m'
C_DIM=$'\033[2m'
C_BOLD=$'\033[1m'
C_RESET=$'\033[0m'

ok()  { printf "  %s✓%s %s\n" "$C_GREEN" "$C_RESET" "$*"; }
ko()  { printf "  %s✗%s %s\n" "$C_RED"   "$C_RESET" "$*"; }
hd()  { printf "\n%s%s%s\n" "$C_BOLD" "$1" "$C_RESET"; }

hd "Buzz — status da estação"

# Configuração presente
if [[ -f "$BUZZ_CONFIG" ]]; then
    ok "Configuração: $BUZZ_CONFIG"
else
    ko "Configuração ausente — instale o Buzz: bash install.sh"
    exit 1
fi

# Processo rodando?
if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active buzz.service >/dev/null 2>&1; then
    ok "Estado: ligado (modo serviço, sempre disponível)"
elif pgrep -f "openclaw run.*${BUZZ_HOME}" >/dev/null 2>&1; then
    ok "Estado: ligado (modo solto)"
else
    ko "Estado: desligado"
    printf "  %sLigue com: buzz start%s\n" "$C_DIM" "$C_RESET"
fi

# Telegram
if [[ -f "$BUZZ_CONFIG" ]] && grep -q '"telegram"' "$BUZZ_CONFIG"; then
    bot_token=$(grep -o '"botToken"[[:space:]]*:[[:space:]]*"[^"]*"' "$BUZZ_CONFIG" | cut -d'"' -f4 || echo "")
    if [[ -n "$bot_token" ]]; then
        bot_info=$(curl -fsS "https://api.telegram.org/bot${bot_token}/getMe" 2>/dev/null || echo '{"ok":false}')
        if echo "$bot_info" | grep -q '"ok":true'; then
            username=$(echo "$bot_info" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
            ok "Telegram: @${username} respondendo"
            printf "  %shttps://t.me/${username}%s\n" "$C_DIM" "$C_RESET"
        else
            ko "Telegram: bot não responde — verifique o token"
        fi
    fi
fi

# Memória
if [[ -d "$BUZZ_HOME/memory" ]]; then
    mem_count=$(find "$BUZZ_HOME/memory" -type f 2>/dev/null | wc -l)
    ok "Memória: $mem_count registros guardados"
fi

# Perfil
if [[ -f "$BUZZ_HOME/perfil.md" ]]; then
    nome=$(grep -o '\*\*Nome:\*\* .*' "$BUZZ_HOME/perfil.md" | sed 's/\*\*Nome:\*\* //' || echo "")
    if [[ -n "$nome" ]]; then
        ok "Operador: $nome"
    fi
fi

echo
