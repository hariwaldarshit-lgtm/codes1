FROM python:3.11-slim

WORKDIR /app

# System deps some tokenizer/model libs need at build time
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . .

# Hugging Face Spaces expects the app on port 7860
ENV PORT=7860
EXPOSE 7860

# Single worker: each gunicorn worker loads its own full copy of the model
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:7860", "--workers", "1", "--threads", "2", "--timeout", "300"]
