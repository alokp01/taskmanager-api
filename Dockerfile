FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# System deps needed to build psycopg2-binary cleanly on slim images
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Collect static files at build time. SECRET_KEY is only needed so
# `manage.py` can boot; DB settings aren't touched by collectstatic.
RUN SECRET_KEY=build-time-placeholder python manage.py collectstatic --noinput

# Cloud Run injects $PORT at runtime; default to 8080 for local docker run
ENV PORT=8080
EXPOSE 8080

CMD exec gunicorn --bind :$PORT --workers 2 --threads 4 --timeout 60 taskmanager.wsgi:application
