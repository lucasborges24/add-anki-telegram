#!/bin/bash
set -e

echo ${ANKI_PROFILE_DIR:-$HOME/.local/share/Anki2}
PROFILE_DIR=${ANKI_PROFILE_DIR:-$HOME/.local/share/Anki2}
ADDON_DIR="$PROFILE_DIR/addons21/2055492159"

mkdir -p "$PROFILE_DIR/addons21"

# copy AnkiConnect addon if not present
if [ ! -d "$ADDON_DIR" ]; then
  cp -r /opt/anki-connect "$ADDON_DIR"
fi

# update port in config if needed
CONFIG_FILE="$ADDON_DIR/config.json"
if [ -n "$ANKICONNECT_PORT" ]; then
  if [ -f "$CONFIG_FILE" ]; then
    sed -i "s/\"webBindPort\": [0-9]\+/\"webBindPort\": $ANKICONNECT_PORT/" "$CONFIG_FILE"
  fi
fi

export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

xvfb-run --server-args="-screen 0 1024x768x24" anki --no-sound &
ANKI_PID=$!

# Aguarda o AnkiConnect responder na porta
echo "Aguardando AnkiConnect iniciar..."
for i in {1..30}; do
  echo "Tentativa $i de 30..."
  if curl -s -X POST http://localhost:${ANKICONNECT_PORT}/ -d '{"action":"version","version":6}' | grep -q '"result"'; then
    echo "AnkiConnect está pronto!"
    break
  fi
  sleep 1
done

python /app/anki_bot.py &
BOT_PID=$!

wait $BOT_PID
kill $ANKI_PID