# Add Anki Telegram

Este projeto fornece um bot do Telegram capaz de gerar definicoes e imagens usando a API da OpenAI e, em seguida, criar flashcards no Anki via AnkiConnect.

## Requisitos

1. Python 3.10 ou superior.
2. Um bot do Telegram, com o token respectivo configurado em `.env`.
3. Chave de API da OpenAI configurada tambem em `.env`.

## Instalacao

Crie um ambiente virtual e instale as dependencias executando:

```bash
pip install -r requirements.txt
```

Este mesmo arquivo pode ser usado em um `Dockerfile` para instalacao das bibliotecas:

```Dockerfile
COPY requirements.txt ./
RUN pip install -r requirements.txt
```

## Uso

Execute o script principal:

```bash
python anki_bot.py
```

O bot iniciara a escuta por mensagens de texto no Telegram e criara cards no Anki conforme descrito no codigo.
