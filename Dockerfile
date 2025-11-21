FROM python:3.11

COPY requirements.txt /tmp/

RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    libssl-dev \
    swig \
    libffi-dev \
    git \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    wget \
    node-less \
    libpq-dev \
    libsasl2-dev \
    libldap2-dev \
    libjpeg-dev \
    liblcms2-dev \
    libblas-dev \
    liblapack-dev \
    xfonts-base \
    xfonts-75dpi \
    libopenblas-dev \
    postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb -O /tmp/wkhtmltopdf.deb \
    && apt-get install -y /tmp/wkhtmltopdf.deb \
    && rm /tmp/wkhtmltopdf.deb \
    && wkhtmltopdf --version

COPY ./community /odoo
WORKDIR /odoo

RUN pip install --no-cache-dir --break-system-packages -r /odoo/requirements.txt
RUN pip install --no-cache-dir --break-system-packages -r /tmp/requirements.txt

EXPOSE 8069 8072