FROM python:3.12-slim

# 1) Versão “launcher” recente
ARG ANKI_RELEASE=25.02.7
ENV ANKI_RELEASE=${ANKI_RELEASE}
ENV ANKICONNECT_PORT=8765

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      xvfb git wget zstd \
      libxcb-xinerama0 libxcb-xtest0 libxcb-shape0 \
      libxcb-render0 libxcb-render-util0 \
 && rm -rf /var/lib/apt/lists/* \
 # baixe o launcher .tar.zst
 && wget -qO /tmp/anki.tar.zst \
        https://github.com/ankitects/anki/releases/download/${ANKI_RELEASE}/anki-${ANKI_RELEASE}-linux-qt6.tar.zst \
 && mkdir -p /opt/anki \
 # descompacta com zstd
 && tar --use-compress-program=unzstd -xf /tmp/anki.tar.zst -C /opt/anki \
 && ln -s /opt/anki/anki-${ANKI_RELEASE}-linux-qt6/anki /usr/local/bin/anki \
 && rm /tmp/anki.tar.zst


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
