#!/usr/bin/env bash
# buzz-start — liga o Buzz
set -e

BUZZ_HOME="${BUZZ_HOME:-$HOME/.buzz}"
BUZZ_CONFIG="${BUZZ_HOME}/config.json"

if [[ ! -f "$BUZZ_CONFIG" ]]; then
    echo "Buzz: não encontrei a configuração em $BUZZ_CONFIG"
    echo "      Você instalou o Buzz? Tente: bash install.sh"
    exit 1
fi

# Tenta systemd primeiro, senão modo solto
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user start buzz.service && {
        echo "Buzz: estação ativada (modo serviço)."
        exit 0
    }
fi

# Modo solto (sem systemd)
if pgrep -f "openclaw run.*${BUZZ_CONFIG}" >/dev/null 2>&1; then
    echo "Buzz: já estou ligado."
    exit 0
fi

nohup openclaw run --config "$BUZZ_CONFIG" > "$BUZZ_HOME/buzz.log" 2>&1 &
sleep 2
echo "Buzz: estação ativada (modo solto). Logs em $BUZZ_HOME/buzz.log"
