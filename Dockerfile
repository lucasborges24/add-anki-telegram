FROM python:3.12-slim

ARG ANKI_RELEASE=25.02.7
ENV ANKI_RELEASE=${ANKI_RELEASE}
ENV ANKICONNECT_PORT=8765

 RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       xvfb git wget zstd curl \
       libdbus-1-3 libdbus-glib-1-2 \
       libasound2 \
       libxcb1 libx11-6 libx11-xcb1 \
       libxcb-xinerama0 libxcb-cursor0 libxcb-icccm4 \
       libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
       libxcb-render0 libxcb-render-util0 libxcb-shape0 \
       libxcb-sync1 libxcb-xfixes0 libxcb-xtest0 libxcb-shm0 \
       libxcb-glx0 libxcb-util1 libxcb-xkb1 \
       libxkbcommon0 libxkbcommon-x11-0 \
       libxdamage1 libxtst6 \
       libsm6 libice6 libxss1 \
       libfontconfig1 libfreetype6 libegl1 \
       libgl1-mesa-glx libgl1-mesa-dri \
       libxrender1 libxrandr2 libxcomposite1 libxcursor1 libxi6 \
       libharfbuzz0b libgraphite2-3 libpcre2-8-0 \
       fonts-dejavu-core fonts-dejavu-extra \
       libnss3 libglib2.0-0 \
 && rm -rf /var/lib/apt/lists/* \
 # baixe o launcher .tar.zst
 && wget -qO /tmp/anki.tar.zst \
        https://github.com/ankitects/anki/releases/download/${ANKI_RELEASE}/anki-${ANKI_RELEASE}-linux-qt6.tar.zst \
 && mkdir -p /opt/anki \
 # descompacta com zstd
 && tar --use-compress-program=unzstd -xf /tmp/anki.tar.zst -C /opt/anki \
 && ln -s /opt/anki/anki-${ANKI_RELEASE}-linux-qt6/anki /usr/local/bin/anki \
 && rm /tmp/anki.tar.zst


# Instala o add-on AnkiConnect
RUN mkdir -p /opt/anki-connect \
 && git clone --depth 1 https://github.com/FooSoft/anki-connect /opt/anki-connect

# Instala os requisitos do requirements.txt
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY anki_bot.py /app/anki_bot.py
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE ${ANKICONNECT_PORT}
VOLUME ["/root/.local/share/Anki2"]
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
