# Add Anki Telegram Bot

This project builds a Docker image containing Anki, the AnkiConnect add-on and a Telegram bot.

## First-time setup

The container starts Anki headlessly under Xvfb and exposes the AnkiConnect port. To synchronise with your AnkiWeb account you must sign in once using the standard Anki interface. The easiest method is:

1. Build the image locally:

```bash
docker build -t add-anki-telegram .
```

2. Run the container interactively with access to your host display:

```bash
docker run --rm -e DISPLAY=your_display -v anki_data:/root/.local/share/Anki2 add-anki-telegram bash
```

3. Inside the container launch `anki` and log in with your AnkiWeb ID and password. These credentials are stored in the mounted profile directory (`anki_data` volume) so subsequent runs will automatically sync.

After logging in you can start the service normally using `docker-compose up -d`.

## Environment variables

- `TELEGRAM_TOKEN` – Token for your Telegram bot
- `OPENAI_API_KEY` – API key for OpenAI
- `ANKICONNECT_PORT` – Port exposed by AnkiConnect (default `8765`)

## Build and run

```bash
docker-compose up --build
```

The profile data is persisted in the `anki_data` volume.
