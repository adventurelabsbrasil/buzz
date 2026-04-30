#!/usr/bin/env bash
# buzz-stop — desliga o Buzz
set -e

BUZZ_HOME="${BUZZ_HOME:-$HOME/.buzz}"

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user stop buzz.service 2>/dev/null && {
        echo "Buzz: estação desligada."
        exit 0
    }
fi

if pgrep -f "openclaw run.*${BUZZ_HOME}" >/dev/null 2>&1; then
    pkill -f "openclaw run.*${BUZZ_HOME}" || true
    sleep 1
    echo "Buzz: estação desligada."
else
    echo "Buzz: já estava desligado."
fi
