# ── Etapa 1: Builder ────────────────────────────────────────────────────────
# Usamos imagen completa SOLO para compilar dependencias con C-extensions
FROM python:3.11-slim AS builder

# Dependencias de compilación (solo en esta etapa, no van a la imagen final)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libssl-dev \
    swig \
    libffi-dev \
    git \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libpq-dev \
    libsasl2-dev \
    libldap2-dev \
    libjpeg-dev \
    liblcms2-dev \
    libblas-dev \
    liblapack-dev \
    libopenblas-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements-extra.txt
# Solo el requirements.txt de Odoo (no el source completo)
COPY community/requirements.txt /tmp/odoo-requirements.txt

RUN pip install --no-cache-dir --upgrade pip "setuptools<70.0.0" wheel setuptools_scm && \
    pip install --no-cache-dir --no-build-isolation cbor2==5.4.2 && \
    pip install --no-cache-dir -r /tmp/odoo-requirements.txt && \
    pip install --no-cache-dir -r /tmp/requirements-extra.txt && \
    pip install --no-cache-dir --force-reinstall gevent zope.interface zope.event

# ── Etapa 2: Runtime ────────────────────────────────────────────────────────
FROM python:3.11-slim

# Solo dependencias de runtime (sin compiladores ni git)
# Incluye las deps de wkhtmltopdf (fontconfig, X11) en el mismo bloque
# para no tener que volver a correr apt-get update
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    node-less \
    libpq5 \
    libsasl2-2 \
    libldap2 \
    libjpeg62-turbo \
    liblcms2-2 \
    libopenblas0 \
    xfonts-base \
    xfonts-75dpi \
    libxml2 \
    libxslt1.1 \
    postgresql-client \
    fontconfig \
    libx11-6 \
    libxcb1 \
    libxext6 \
    libxrender1 \
    && wget -q https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb -O /tmp/wkhtmltopdf.deb \
    && apt-get install -y /tmp/wkhtmltopdf.deb \
    && rm /tmp/wkhtmltopdf.deb \
    && rm -rf /var/lib/apt/lists/* \
    && wkhtmltopdf --version

# Copiar paquetes Python ya compilados desde el builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# El código fuente de Odoo se monta en runtime via volumen: ./community:/odoo
# NO se copia aquí → ahorra ~500MB-1GB en la imagen final
WORKDIR /odoo

EXPOSE 8069 8072