# Add Anki Telegram Bot

This project builds a Docker image containing Anki, the AnkiConnect add-on and a Telegram bot.

## First-time setup: Log in to AnkiWeb

Before running the bot service, you **must log in to your AnkiWeb account** inside the container to enable synchronization. This only needs to be done once, and your credentials will be saved in the `anki_data` volume.

### Steps:

1. **Allow Docker to access your X server:**
   ```bash
   xhost +local:docker
   ```

2. **Start the container with GUI support:**
   ```bash
   sudo docker run --rm -it \
     --entrypoint /bin/bash \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     -e DISPLAY=$DISPLAY \
     -v anki_data:/root/.local/share/Anki2 \
     -v "$(pwd)/.env":/app/.env:ro \
     -e QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox --disable-gpu" \
     add-anki-telegram
   ```

3. **Inside the container, launch Anki:**
   ```bash
   anki
   ```
   Log in with your AnkiWeb ID and password.  
   Adicione a extensão do anki connect
   After logging in, you can close Anki and exit the container.

4. **Now you can start the service normally:**
   ```bash
   docker-compose up --build -d
   ```

## Environment variables

- `TELEGRAM_TOKEN` – Token for your Telegram bot
- `OPENAI_API_KEY` – API key for OpenAI
- `ANKICONNECT_PORT` – Port exposed by AnkiConnect (default `8765`)

## Build and run

```bash
docker-compose up --build
```

The profile data is persisted in the `anki_data` volume.