import os
import logging
import io
import base64
import requests
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import ApplicationBuilder, MessageHandler, ContextTypes, filters
from openai import OpenAI

# carrega variáveis de ambiente do .env
load_dotenv()
TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

if not TELEGRAM_TOKEN:
    raise RuntimeError("Defina TELEGRAM_TOKEN no .env")
if not OPENAI_API_KEY:
    raise RuntimeError("Defina OPENAI_API_KEY no .env")

# instancia o client do OpenAI
client = OpenAI(api_key=OPENAI_API_KEY)

# configura o logging
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)

async def log_palavra(update: Update, context: ContextTypes.DEFAULT_TYPE):
    palavra = update.message.text.strip()
    logging.info(f"essa é a palavra que vc enviou: {palavra}")

    # 1) Obter definição objetiva e exemplo criativo
    try:
        resp = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "Você é um escritor criativo que mantém objetividade."},
                {"role": "user", "content":
                    f"Para a palavra **{palavra}**, forneça:\n"
                    "1. Uma definição objetiva em até 20 palavras.\n"
                    "2. Um exemplo de frase criativa e envolvente que utilize a palavra em negrito."
                }
            ],
            temperature=0.7,
            max_tokens=120,
        )
        conteudo = resp.choices[0].message.content.strip()
    except Exception as e:
        logging.error(f"Erro na API OpenAI (chat): {e}")
        await update.message.reply_text("Desculpe, não consegui gerar a definição agora.")
        return

    # separa definição e exemplo
    linhas = [l for l in conteudo.split("\n") if l.strip()]
    defin = linhas[0].partition("1.")[2].strip() if "1." in linhas[0] else linhas[0]
    exemplo = ""
    if len(linhas) > 1:
        exemplo = linhas[1].partition("2.")[2].strip() if "2." in linhas[1] else linhas[1]

    # 2) Gerar imagem baseada no exemplo
    img_data = None
    if exemplo:
        try:
            prompt_img = f"Crie uma imagem detalhada que represente esta frase: “{exemplo}”"
            img_resp = client.images.generate(
                model="dall-e-3",
                prompt=prompt_img,
                n=1,
                size="1024x1024",
            )
            url = img_resp.data[0].url
            img_data = requests.get(url).content
        except Exception as e:
            logging.error(f"Erro na API OpenAI (images): {e}")
            img_data = None

    # 3) Envia definição e exemplo no Telegram
    texto = f"Definição: {defin}\n\nExemplo: {exemplo}"
    await update.message.reply_text(texto)

    # 4) Envia imagem, se disponível
    if img_data:
        bio = io.BytesIO(img_data)
        bio.name = "image.png"
        bio.seek(0)
        await context.bot.send_photo(chat_id=update.effective_chat.id, photo=bio)

    # 5) Cria o card no Anki via AnkiConnect
    try:
        # transforma imagem em base64
        picture = []
        if img_data:
            img_b64 = base64.b64encode(img_data).decode("utf-8")
            picture = [{
                "data": img_b64,
                "filename": "image.png",
                "fields": "Front"
            }]

        note = {
            "deckName": "RD",           # ou o nome do seu baralho
            "modelName": "Basic",            # ou o nome do seu modelo
            "fields": {
                "Front": "<img src='image.png'><br><br>" + palavra,
                "Back": defin + "<br><br>" + exemplo
            },
            "options": {"allowDuplicate": False},
            "tags": [],
            "picture": picture
        }

        payload = {
            "action": "addNote",
            "version": 6,
            "params": {"note": note}
        }
        resp = requests.post("http://localhost:8765", json=payload).json()
        logging.info(f"AnkiConnect response: {resp}")
    except Exception as e:
        logging.error(f"Erro ao criar card no Anki: {e}")

def main():
    app = ApplicationBuilder().token(TELEGRAM_TOKEN).build()
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, log_palavra))
    print("Bot iniciado. Pressione Ctrl+C para parar.")
    app.run_polling()

if __name__ == "__main__":
    main()
