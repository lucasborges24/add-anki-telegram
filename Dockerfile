FROM python:3.12-slim

ENV ANKICONNECT_PORT=8765

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       anki xvfb git \
    && rm -rf /var/lib/apt/lists/*

# install AnkiConnect addon
RUN mkdir -p /opt/anki-connect \
    && git clone --depth 1 https://github.com/FooSoft/anki-connect /opt/anki-connect

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY anki_bot.py /app/anki_bot.py
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE ${ANKICONNECT_PORT}
VOLUME ["/root/.local/share/Anki2"]
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
